import numpy as np
import geojson
import xarray
import icepack

# Fetch the outline of Larsen and compute a bounding box
outline_filename = icepack.datasets.fetch_larsen_outline()
with open(outline_filename, 'r') as outline_file:
    outline = geojson.load(outline_file)

coords = np.array(list(geojson.utils.coords(outline)))
xmin, xmax = coords[:, 0].min(), coords[:, 0].max()
ymin, ymax = coords[:, 1].min(), coords[:, 1].max()

delta = 10e3

# Fetch the MEaSUREs ice velocities and extract the region around Larsen
measures_filename = icepack.datasets.fetch_measures_antarctica()
dataset = xarray.open_dataset(measures_filename)
output_dataset = dataset[['VX', 'VY', 'ERRX', 'ERRY']].sel(
    x=slice(xmin - delta, xmax + delta), y=slice(ymax - delta, ymin + delta)
)
output_dataset.to_netcdf('measures.nc')
