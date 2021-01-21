import argparse
import geojson
import numpy as np
import icepack
import tqdm
import xarray


glacier_names = ['larsen', 'pine-island']
outlines = []
for name in glacier_names:
    filename = icepack.datasets.fetch_outline(name)
    with open(filename, 'r') as outline_file:
        outline = geojson.load(outline_file)
        outlines.append(outline)


def bounding_box(outline, delta=5e3):
    coords = np.array(list(geojson.utils.coords(outline)))
    x, y = coords[:, 0], coords[:, 1]
    return x.min() - delta, y.min() - delta, x.max() + delta, y.max() + delta


def mask_data(dataset, outlines):
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


# Fetch the MEaSUREs ice velocities and mask out everything except for Larsen C
# Ice Shelf and Pine Island Glacier
# NOTE: The MEaSUREs velocity dataset stores the lat/lon coordinates of each
# grid point as 64-bit floats; dropping these fields shrinks the size of the
# output file by a factor of 5.
filename = icepack.datasets.fetch_measures_antarctica()
measures = xarray.open_dataset(filename).drop(['lat', 'lon'])
mask_data(measures, outlines)

# Same but for BedMachine
filename = icepack.datasets.fetch_bedmachine_antarctica()
bedmachine = xarray.open_dataset(filename)
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
measures.to_netcdf(
    'measures.nc',
    encoding={key: enc for key in measures.keys() if measures[key].shape}
)
bedmachine.to_netcdf(
    'bedmachine.nc',
    encoding={key: enc for key in bedmachine.keys() if bedmachine[key].shape}
)
