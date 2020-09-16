import numpy as np
import geojson
import xarray
import rasterio
from rasterio.windows import Window, window_index
import icepack

def complement(window, shape):
    r"""Return windows describing the set complement or outside of a window"""
    rowmin, colmin = window.row_off, window.col_off
    rowmax, colmax = rowmin + window.height, colmin + window.width
    windows = [
        Window.from_slices((0, rowmax), (0, colmin)),
        Window.from_slices((rowmax, shape[0]), (0, colmax)),
        Window.from_slices((rowmin, shape[0]), (colmax, shape[1])),
        Window.from_slices((0, rowmin), (colmin, shape[1]))
    ]
    return [w for w in windows if w.width != 0 and w.height != 0]


measures_filename = icepack.datasets.fetch_measures_antarctica()

outline_filenames = [
    icepack.datasets.fetch_larsen_outline()
]

with rasterio.open(f'netcdf:{measures_filename}:VX', 'r') as dataset:
    windows = [Window.from_slices((0, dataset.shape[0]), (0, dataset.shape[1]))]
    for filename in outline_filenames:
        with open(filename, 'r') as outline_file:
            outline = geojson.load(outline_file)

        coords = np.array(list(geojson.utils.coords(outline)))
        xmin, xmax = coords[:, 0].min(), coords[:, 0].max()
        ymin, ymax = coords[:, 1].min(), coords[:, 1].max()

        delta = 10e3

        rowmin, colmin = dataset.index(xmin - delta, ymax + delta)
        rowmax, colmax = dataset.index(xmax + delta, ymin - delta)

        window_interior = Window.from_slices((rowmin, rowmax), (colmin, colmax))
        windows_exterior = complement(window_interior, dataset.shape)

        new_windows = []
        for w1 in windows_exterior:
            for w2 in windows:
                w = w1.intersection(w2)
                if w.height != 0 and w.width != 0:
                    new_windows.append(w)

        windows = new_windows

import matplotlib.pyplot as plt
fig, axes = plt.subplots()
a = np.zeros(dataset.shape)
for window in windows:
    rowslice, colslice = window_index(window)
    a[rowslice, colslice] = 1.
axes.imshow(a)
plt.show()

# Fetch the MEaSUREs ice velocities and extract the region around Larsen
dataset = xarray.open_dataset(measures_filename, chunks={'x': 1000, 'y': 1000})
keys = ['VX', 'VY', 'ERRX', 'ERRY']

for key in keys:
    for window in windows:
        pass

exit()

encoding = {key: {'zlib': True, 'complevel': 9} for key in keys}
dataset.to_netcdf('measures.nc', encoding=encoding)
