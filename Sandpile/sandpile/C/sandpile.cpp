#include <iostream>
#include <vector>
#include <queue>
#include <time.h>
#include <stdlib.h>
#include <png++/png.hpp>

class Tuple {
	private:
		int x, y;

	public:
		Tuple(int x, int y) {
			this->x = x;
			this->y = y;
		}

		int getX() {
			return x;
		}

		int getY() {
			return y;
		}
};

class Sandpile {
	private:
		int dim;
		std::vector<int> pile;
		
	public:
		Sandpile(int dim) {
			this->dim = dim;
			this->pile = std::vector<int>(dim*dim);
		}

		int get(int i, int j) {
			return pile[i + j*dim];
		}

		int get(Tuple t) {
			return get(t.getX(), t.getY());
		}

		void set(int i, int j, int e) {
			pile[i + j*dim] = e;
		}

		void set(Tuple t, int e) {
			set(t.getX(), t.getY(), e);
		}

		void setMid(int e) {
			set(dim/2, dim/2, e);
		}

		void normalize() {
			std::deque<Tuple> q;
			bool sym_hor = true;
			bool sym_vert = true;
			std::cout << "Sandpile dimension is " << this->dim << std::endl;

			// determine is sandpile is symmetric
			for (int i = 0; i < this->dim; ++i) {
				for (int j = 0; j < this->dim; ++j) {
					if (i < this->dim/2) sym_hor &= this->get(i,j) == this->get(this->dim-1-i, j);
					if (j < this->dim/2) sym_vert &= this->get(i,j) == this->get(i, this->dim-1-j);
				}
			}
			std::cout << "Sandpile is " << (sym_hor?"":"not ") << "horizontally symmetric" << std::endl;
			std::cout << "Sandpile is " << (sym_vert?"":"not ") << "vertically symmetric" << std::endl;


			// populate queue; Queue only contains entries > 3 after this
			int axis_hor = sym_hor?(this->dim+1)/2:this->dim-1;
			int axis_vert = sym_vert?(this->dim+1)/2:this->dim-1;
			for (int i = 0; i <= axis_hor; ++i) {
				for (int j = 0; j <= axis_vert; ++j) {
					if (this->get(i,j) > 3) q.push_back(Tuple(i,j));
				}
			}
			std::cout << "Populated the queue with initial indexes, considering a " << axis_hor << " by " << axis_vert << " grid" << std::endl;

			// topple the entries; don't bother with cells across the axis if symmetric
			while (q.size() != 0) {
				Tuple t = q.front();
				q.pop_front();
				if (this->get(t) > 3) {
					int inc = this->get(t)/4;
					this->set(t, this->get(t)%4);

					int a = t.getX();
					int b = t.getY();

					if (a > 0) {
						this->set(a-1,b,this->get(a-1,b)+inc);
						if (this->get(a-1,b) > 3) q.push_back(Tuple(a-1,b));
					}
					if (b > 0) {
						this->set(a,b-1,this->get(a,b-1)+inc);
						if (this->get(a,b-1) > 3) q.push_back(Tuple(a,b-1));
					}
					if (a < this->dim-1 && (!sym_hor || a < (this->dim+1)/2)) {
						if (a+1==(this->dim+1)/2) this->set(a+1,b,this->get(a+1,b)+inc);
						this->set(a+1,b,this->get(a+1,b)+inc);
						if (this->get(a+1,b) > 3) q.push_back(Tuple(a+1,b));
					}
					if (b < this->dim-1 && (!sym_vert || b < (this->dim+1)/2)) {
						if (b+1==(this->dim+1)/2) this->set(a,b+1,this->get(a,b+1)+inc);
						this->set(a,b+1,this->get(a,b+1)+inc);
						if (this->get(a,b+1) > 3) q.push_back(Tuple(a,b+1));
					}
				}
			}
			std::cout << "Toppled all entries, no more values > 3" << std::endl;

			// copy entries due to symmetry
			if (sym_hor) {
				for (int i = 0; i <= axis_hor; ++i) {
					for (int j = 0; j < this->dim; ++j) {
						this->set(this->dim-1-i,j,this->get(i,j));
					}
				}
				std::cout << "Copied values due to horizontal symmetry" << std::endl;
			}
			if (sym_vert) {
				for (int i = 0; i < this->dim; ++i) {
					for (int j = 0; j <= axis_vert; ++j) {
						this->set(i,this->dim-1-j,this->get(i,j));
					}
				}
				std::cout << "Copied values due to vertical symmetry" << std::endl;
			}
		}

		png::rgb_pixel getColor(int marker) {
			switch(marker) {
				case 0: return png::rgb_pixel(54,22,184);
				case 1:	return png::rgb_pixel(207,112,52);
				case 2:	return png::rgb_pixel(65,113,159);
				case 3: return png::rgb_pixel(126,0,0);
			}
		}

		void createImage(std::string path) {
			png::image<png::rgb_pixel> image(this->dim, this->dim);
			for (png::uint_32 i = 0; i < image.get_width(); ++i) {
				for (png::uint_32 j = 0; j < image.get_height(); ++j) {
					image.set_pixel(i,j,this->getColor(this->get(i,j)));
				}
			}
			image.write(path);
		}
};

int main(int argc, char* argv[]) {
	int dim = 129;
	int sand = 1028;
	std::string path = "..\\fractal.png";
	for (int i = 0; i < argc; ++i) {
		if (std::string(argv[i]) == "--size" && i+1 <= argc) dim = atoi(argv[i+1]);
		if (std::string(argv[i]) == "--value" && i+1 <= argc) sand = atoi(argv[i+1]);
		if (std::string(argv[i]) == "--path" && i+1 <= argc) path = std::string(argv[i+1]);
	}
	clock_t start = clock();
	Sandpile pile = Sandpile(dim);
	pile.setMid(sand);
	pile.normalize();
	pile.createImage(path);
	clock_t end = clock()-start;
	std::cout << "Task took " << end/CLOCKS_PER_SEC << " seconds" << std::endl;
	return 0;
}