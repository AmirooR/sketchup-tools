import numpy as np
from PIL import Image

def visualizeNormalMapFile(inFileX,inFileY,inFileZ, outFile):
	nx = np.loadtxt(inFileX)
	ny = np.loadtxt(inFileY)
	nz = np.loadtxt(inFileZ)

	b = np.zeros((nx.shape[0],nx.shape[1],3),'float32')
	b[:,:,0] = (nx+1)/2
	b[:,:,1] = (ny+1)/2
	b[:,:,2] = (nz+1)/2
	e = 255.*b
	img = Image.fromarray(e.astype('uint8'))
	img.save(outFile)

def visualizeDepth(inFile, outFile):
	depths = np.loadtxt(inFile)
	e = depths*255./depths.max()
	img = Image.fromarray(e.astype('uint8'))
	img.convert('L').save(outFile)

def imageToNormal(inFile, outFile):
	im = Image.open(inFile)
	a = np.asarray(im).astype('float32')
	a = (a - 128.)/128.
	k = np.sqrt( a[:,:,0]**2 + a[:,:,1]**2 + a[:,:,1]**2 + 0.000001)
	a[:,:,0] /= k
	a[:,:,1] /= k
	a[:,:,2] /= k
	a = 0.5*(a + 1)
	a = 255.*a
	im = Image.fromarray(a.astype('uint8'))
	im.save(outFile)
