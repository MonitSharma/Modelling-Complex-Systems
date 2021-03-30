CXX = g++
CFLAGS = -O3 -g
PNGFLAGS = `libpng-config --cflags --ldflags`

all:
	$(CXX) sandpile.cpp -o sandpile $(CFLAGS) $(PNGFLAGS)
clean:
	rm sandpile