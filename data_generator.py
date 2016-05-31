import random

random.seed()
f = open('C:\\Users\\Kacp\\Desktop\\studia\\vhdl\\serdes0\\input_data.txt', 'wt')
f.seek(0)

def generuj(x,y):
    for i in range(0,x):
        for j in range(0,20):
            if (j == 0):
                byte = hex(126)
            elif (j < 17):
                byte = hex(random.randint(0,255))
            else:
                if(y):
                    byte = hex(0)
                
            hex_byte = byte[2:].zfill(2)
            print(hex_byte)
            f.write(hex_byte)
            f.write('\n')

generuj(int(input('podaj ilosc pakietow: ')), int(input('bajty stopu?[0/1]')))

if not f.closed: f.close()
