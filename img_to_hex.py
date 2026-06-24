from PIL import Image


img = Image.open("thermal.png").convert("L")
img = img.resize((16,16))

with open("image.hex","w") as f:
    for p in img.getdata():
        f.write(f"{p:02X}\n")