import os
import geojson
import hashlib
import numpy as np
import icepack
import tqdm
import xarray


def bounding_box(outline, delta=5e3):
    r"""Get a bounding box for a GeoJSON object with some extra padding"""
    coords = np.array(list(geojson.utils.coords(outline)))
    x, y = coords[:, 0], coords[:, 1]
    return x.min() - delta, y.min() - delta, x.max() + delta, y.max() + delta


def mask_data(dataset, outlines):
    r"""Mask out every value in an xarray dataset for points outside the input
    set of outlines"""
    x = dataset.coords['x']
    y = dataset.coords['y']
    for name in tqdm.tqdm(dataset.keys()):
        array = dataset[name].copy(deep=True)
        if array.shape:
            array[:, :] = np.nan

            for outline in outlines:
                xmin, ymin, xmax, ymax = bounding_box(outline)
                xslice = x[(x >= xmin) & (x <= xmax)]
                yslice = y[(y >= ymin) & (y <= ymax)]
                selection = {'x': xslice, 'y': yslice}
                array.loc[selection] = dataset[name].loc[selection]

            dataset[name][:, :] = array[:, :]


def sha256sum(filename, blocksize=65536):
    r"""Compute the SHA256 hash of a file on disk"""
    checksum = hashlib.sha256()
    with open(filename, 'rb') as f:
        for block in iter(lambda: f.read(blocksize), b''):
            checksum.update(block)

    return checksum.hexdigest()


# Fetch the outlines of the glaciers (Larsen and Pine Island) for which we want
# to have data in the Docker image.
glacier_names = ['larsen', 'pine-island']
outlines = []
for name in glacier_names:
    filename = icepack.datasets.fetch_outline(name)
    with open(filename, 'r') as outline_file:
        outline = geojson.load(outline_file)
        outlines.append(outline)

# Fetch the MEaSUREs ice velocities and mask out everything except for the
# glaciers we're testing on.
# NOTE: The MEaSUREs velocity dataset stores the lat/lon coordinates of each
# grid point as 64-bit floats; dropping these fields shrinks the size of the
# output file by a factor of 5.
measures_pathname = icepack.datasets.fetch_measures_antarctica()
measures = xarray.open_dataset(measures_pathname).drop(['lat', 'lon'])
mask_data(measures, outlines)

# Same but for BedMachine
bedmachine_pathname = icepack.datasets.fetch_bedmachine_antarctica()
bedmachine = xarray.open_dataset(bedmachine_pathname)
mask_data(bedmachine, outlines)

# Write everything out to NetCDF
enc = {
    'zlib': True,
    'shuffle': True,
    'complevel': 1,
    'fletcher32': False,
    'contiguous': False,
    'chunksizes': (768, 768),
}
measures_filename = os.path.basename(measures_pathname)
measures.to_netcdf(
    measures_filename,
    encoding={key: enc for key in measures.keys() if measures[key].shape}
)
bedmachine_filename = os.path.basename(bedmachine_pathname)
bedmachine.to_netcdf(
    bedmachine_filename,
    encoding={key: enc for key in bedmachine.keys() if bedmachine[key].shape}
)

# Create a new registry file with the new SHA256 checksums for the smaller data
registry = icepack.datasets.nsidc_data.registry
registry[bedmachine_filename] = sha256sum(bedmachine_filename)
registry[measures_filename] = sha256sum(measures_filename)

with open('registry-nsidc.txt', 'w') as registry_file:
    for filename, checksum in registry.items():
        registry_file.write(f'{filename} {checksum}\n')
