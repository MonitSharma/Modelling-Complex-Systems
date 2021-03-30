import java.util.Arrays;
import java.util.ArrayDeque;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import javax.imageio.ImageIO;

public class Sandpile {

	private int dim;
	private int[][] pile;

	private final int LIGHTBLUE = 0x41719f;
	private final int PURPLE = 0x3616b8;
	private final int DARKRED = 0x7e0000;
	private final int ORANGE = 0xcf7034;

	public Sandpile(int dim, int pile[][]) {
		this.dim = dim;
		this.pile = pile;
	}

	public Sandpile(int dim) {
		this.dim = dim;
		this.pile = new int[dim][dim];
	}

	public Sandpile() {
		this.dim = 3;
		this.pile = new int[3][3];
	}

	public String toString() {
		String s = "";
		for (int i = 0; i < this.dim; ++i) {
			s += Arrays.toString(this.pile[i])+'\n';
		}
		return s.substring(0,s.length()-1);
	}

	public void max() {
		for (int i = 0; i < this.dim; ++i) {
			for (int j = 0; j < this.dim; ++j) {
				this.pile[i][j] = 3;
			}
		}
	}

	public void normalize() {
		ArrayDeque<Tuple> queue = new ArrayDeque<Tuple>(dim);
		boolean sym_hor = true;
		boolean sym_vert = true;
		System.out.println("Sandpile dimension is " + this.dim);

		// determine is sandpile is symmetric
		for (int i = 0; i < this.dim; ++i) {
			for (int j = 0; j < this.dim; ++j) {
				if (i < this.dim/2) sym_hor &= this.pile[i][j] == this.pile[this.dim-1-i][j];
				if (j < this.dim/2) sym_vert &= this.pile[i][j] == this.pile[i][this.dim-1-j];
			}
		}
		System.out.println("Sandpile is " + (sym_hor?"":"not ") + "horizontally symmetric");
		System.out.println("Sandpile is " + (sym_vert?"":"not ") + "vertically symmetric");


		// populate queue; Queue only contains entries > 3 after this
		int axis_hor = sym_hor?(this.dim+1)/2:this.dim-1;
		int axis_vert = sym_vert?(this.dim+1)/2:this.dim-1;
		for (int i = 0; i <= axis_hor; ++i) {
			for (int j = 0; j <= axis_vert; ++j) {
				if (this.pile[i][j] > 3) queue.add(new Tuple(i,j));
			}
		}
		System.out.println("Populated the queue with initial indexes, considering a " + axis_hor + " by " + axis_vert + " grid");

		// topple the entries; don't bother with cells across the axis if symmetric
		while (queue.size() != 0) {
			Tuple t = queue.poll();
			if (this.get(t) > 3) {
				int inc = this.get(t)/4;
				this.set(t, this.get(t)%4);

				int a = t.getX();
				int b = t.getY();
				
				if (a > 0) {
					this.set(a-1,b,this.get(a-1,b)+inc);
					if (this.get(a-1,b) > 3) queue.add(new Tuple(a-1,b));
				}
				if (b > 0) {
					this.set(a,b-1,this.get(a,b-1)+inc);
					if (this.get(a,b-1) > 3) queue.add(new Tuple(a,b-1));
				}
				if (a < this.dim-1 && (!sym_hor || a < (this.dim+1)/2)) {
					if (a+1==(this.dim+1)/2) this.set(a+1,b,this.get(a+1,b)+inc);
					this.set(a+1,b,this.get(a+1,b)+inc);
					if (this.get(a+1,b) > 3) queue.add(new Tuple(a+1,b));
				}
				if (b < this.dim-1 && (!sym_vert || b < (this.dim+1)/2)) {
					if (b+1==(this.dim+1)/2) this.set(a,b+1,this.get(a,b+1)+inc);
					this.set(a,b+1,this.get(a,b+1)+inc);
					if (this.get(a,b+1) > 3) queue.add(new Tuple(a,b+1));
				}
			}
		}
		System.out.println("Toppled all entries, no more values > 3");

		// copy entries due to symmetry
		if (sym_hor) {
			for (int i = 0; i <= axis_hor; ++i) {
				for (int j = 0; j < this.dim; ++j) {
					this.set(this.dim-1-i,j,this.get(i,j));
				}
			}
			System.out.println("Copied values due to horizontal symmetry");
		}
		if (sym_vert) {
			for (int i = 0; i < this.dim; ++i) {
				for (int j = 0; j <= axis_vert; ++j) {
					this.set(i,this.dim-1-j,this.get(i,j));
				}
			}
			System.out.println("Copied values due to vertical symmetry");
		}
	}

	public void saveImg(String path) {
		this.normalize();
		BufferedImage img = new BufferedImage(this.getDim(), this.getDim(), BufferedImage.TYPE_INT_RGB);
		for (int i = 0; i < this.getDim(); ++i) {
			for (int j = 0; j < this.getDim(); ++j) {
				if (this.get(i,j) == 0) img.setRGB(i,j,PURPLE);
				if (this.get(i,j) == 1) img.setRGB(i,j,ORANGE);
				if (this.get(i,j) == 2) img.setRGB(i,j,LIGHTBLUE);
				if (this.get(i,j) == 3) img.setRGB(i,j,DARKRED);
			}	
		}
		System.out.println("Generated image");
		File f = new File(path);
		try {
			ImageIO.write(img, "PNG", f);
		}
		catch (IOException e) {
			e.printStackTrace();
		}
	}

	public int getDim() {
		return this.dim;
	}

	public void setDim(int dim) {
		this.dim = dim;
	}

	public int[][] getPile() {
		return this.pile;
	}

	public void setPile(int[][] pile) {
		this.pile = pile;
	}

	public void set(int x, int y, int e) {
		this.pile[x][y] = e;
	}

	public void set(Tuple t, int e) {
		this.set(t.getX(), t.getY(), e);
	}

	public void setMid(int e) {
		if (this.dim < 1) return;
		else if (this.dim%2 == 1) this.pile[(this.dim-1)/2][(this.dim-1)/2] = e;
		else {
			this.pile[this.dim/2][this.dim/2] = e;
			this.pile[(this.dim-1)/2][this.dim/2] = e;
			this.pile[this.dim/2][(this.dim-1)/2] = e;
			this.pile[(this.dim-1)/2][(this.dim-1)/2] = e;
		}
	}

	public void setCorner(int e) {
		if (this.dim < 1) return;
		this.pile[this.dim-1][this.dim-1] = e;
	}

	public int get(Tuple t) {
		return this.pile[t.getX()][t.getY()];
	}

	public int get(int x, int y) {
		return this.pile[x][y];
	}

	class Tuple {

		private int x;
		private int y;

		public Tuple(int x, int y) {
			this.x = x;
			this.y = y;
		}

		public int getX() {
			return this.x;
		}

		public int getY() {
			return this.y;
		}

		public String toString() {
			return "("+x+","+y+")";
		}
	}

	public static void main(String[] args) {
		int dim = 129;
		int sand = 1028;
		String path = "../fractal.png";
		for (int i = 0; i < args.length; ++i) {
			if (args[i].matches("-s|--size") && i+1 <= args.length) dim = parseInt(args[i+1], "--size");
			if (args[i].matches("-v|--value") && i+1 <= args.length) sand = parseInt(args[i+1], "--value");
			if (args[i].matches("-p|--path") && i+1 <= args.length) path = args[i+1];
		}
		
		long start = System.currentTimeMillis();
		Sandpile pile = new Sandpile(dim);
		pile.setMid(sand);
		pile.saveImg(path);
		long stop = System.currentTimeMillis();
		long duration = (stop-start)/(1000);
		System.out.println("Task took " + duration + " seconds");
	}

	public static int parseInt(String arg, String purpose) {
		try {
			return Integer.parseInt(arg);
		} catch(NumberFormatException e) {
			System.err.println("Argument of " + purpose + " has to be an Integer. (provided \"" + arg + "\")");
			System.exit(1);
			return 0;
		}
	}
}