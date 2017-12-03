from PIL import Image

img = Image.open("char8x8.png").convert("RGB")
pix = list(img.getdata())

out = open("ascii_bin", "w")

for i in range(128**2):
	ic = i % 64
	lc, cc = ic//8, ic%8
	ia = i // 64
	l, c = ia//16, ia%16
	b = '1' if pix[(l*8+lc) * 128 + (c*8+cc)][1] == 255 else '0'
	out.write(b)

out.close()

s = ""
for i in range(64, 128):
	ic = i % 64
	lc, cc = ic//8, ic%8
	ia = i // 64
	l, c = ia//16, ia%16
	s += '1 ' if pix[(l*8+lc) * 128 + (c*8+cc)][1] == 255 else '0 '
	if i % 8 == 7:
		print(s)
		s = ""
