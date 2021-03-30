import sys, getopt
import numpy as np
import scipy.misc as smp
import time
from collections import deque
import imageio

colors = {1 : [207,112,52],
		2 : [65,113,159],
		3 : [126,0,0],
		0 : [54,22,184]}

class Sandpile:
	"""Sandpile data structure, topple if entry >3"""

	def __init__(self, dim=3):
		self.dim = dim
		self.pile = [x[:] for x in [[0] * dim] * dim]
		#self.pile = np.zeros((dim,dim), dtype=np.int)

	def __str__(self):
		return str(self.pile)

	def set(self, x, y, e):
		self.pile[x][y] = e

	def get(self, x, y):
		return self.pile[x][y]

	def mid(self, e):
		if self.dim <= 0:
			return
		if self.dim%2 == 0:
			self.set(self.dim//2, self.dim//2, e)
			self.set(self.dim//2, (self.dim//2)-1, e)
			self.set((self.dim//2)-1, self.dim//2, e)
			self.set((self.dim//2)-1, (self.dim//2)-1, e)
		if self.dim%2 == 1:
			self.set(self.dim//2, self.dim//2, e)

	def normalize(self):
		q = deque() # contains only indices with value >3

		sym_hor = True
		sym_vert = True
		print("Sandpile dimension is " + str(self.dim))

		# determine is sandpile is symmetric
		for i in range(self.dim):
			for j in range(self.dim):
				if i < self.dim//2:
					sym_hor &= self.get(i,j) == self.get(self.dim-1-i,j)
				if j < self.dim//2:
					sym_vert &= self.get(i,j) == self.get(i,self.dim-1-j)

		print("Sandpile is " + (""if sym_hor else "not") + "horizontally symmetric")
		print("Sandpile is " + (""if sym_hor else "not") + "vertically symmetric")

		# Look for values greater than 3, put those indices into a queue
		axis_hor = (self.dim+1)//2 if sym_hor else self.dim-1
		axis_vert = (self.dim+1)//2 if sym_vert else self.dim-1
		for i in range(axis_hor):
			for j in range(axis_vert):
				if self.get(i,j) > 3:
					q.append((i,j))
		print("Populated the queue with initial indexes, considering a " + str(axis_hor) + " by " + str(axis_vert) + " grid")

		while len(q) != 0:
			(a,b) = q.popleft()
			if self.get(a,b) > 3:	
				inc = self.get(a,b)//4
				self.set(a,b,self.get(a,b)%4)
				if a > 0:
					self.set(a-1,b,self.get(a-1,b)+inc)
					if self.get(a-1,b) > 3:
						q.append((a-1,b))
				if b > 0:
					self.set(a,b-1,self.get(a,b-1)+inc)
					if self.get(a,b-1) > 3:
						q.append((a,b-1))
				if a < self.dim-1 and (not sym_hor or a < (self.dim+1)//2):
					if a+1 == (self.dim+1)//2:
						self.set(a+1,b,self.get(a+1,b)+inc)
					self.set(a+1,b,self.get(a+1,b)+inc)
					if self.get(a+1,b) > 3:
						q.append((a+1,b))
				if b < self.dim-1 and (not sym_vert or b < (self.dim+1)//2):
					if b+1 == (self.dim+1)//2:
						self.set(a,b+1,self.get(a,b+1)+inc)	
					self.set(a,b+1,self.get(a,b+1)+inc)
					if self.get(a,b+1) > 3:
						q.append((a,b+1))

		print("Toppled all entries, no more values > 3")

		# copy entries due to symmetry
		if sym_hor:
			for i in range(axis_hor):
				for j in range(self.dim):
					self.set(self.dim-1-i,j,self.get(i,j))
			print("Copied values due to horizontal symmetry")

		if sym_vert: 
			for i in range(self.dim):
				for j in range(axis_vert):
					self.set(i,self.dim-1-j,self.get(i,j))
			print("Copied values due to vertical symmetry")
		
	def toFractal(self, path):
		self.normalize()
		print("Finished Normalizing...")
		data = np.zeros((self.dim, self.dim, 3), dtype=np.uint8)
		for i in range(self.dim):
			for j in range(self.dim):
				data[i,j] = colors[self.get(i,j)]
		imageio.imwrite(path, data)

def main(argv):
	now = time.time()
	size = 300
	sand = 10000
	path = "fractal.png"
	try:
		opts, args = getopt.getopt(argv,"hs:v:p:",["size=", "sand=", "path="])
	except getopt.GetoptError:
		print("usage: sandpile.py -s <size> -v<value> -p <ofilepath>")
		sys.exit(2)
	for opt, arg in opts:
		if opt == "-h":
			print("usage: sandpile.py -s <size> -v<value> -p <ofilepath>")
			sys.exit()
		elif opt in ("-s", "--size"):
			size = int(arg)
		elif opt in ("-v", "--sand"):
			sand = int(arg)
		elif opt in ("-p", "--path"):
			path = arg
	pile = Sandpile(size)
	pile.mid(sand)
	print("Building Fractal...")
	pile.toFractal(path)
	end = time.time() - now
	print("Task took " + str(end) + " seconds")

if __name__ == "__main__":
	main(sys.argv[1:])