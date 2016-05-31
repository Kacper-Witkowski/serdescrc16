def vect_fill():
    with open('C:\\Users\\Kacp\\Desktop\\studia\\vhdl\\serdes0\\input_data.txt', 'rt') as inp_file:
        global inp_vector
        inp_vector = inp_file.readlines()

    with open('C:\\Users\\Kacp\\Desktop\\studia\\vhdl\\serdes0\\output_data.txt', 'rt') as out_file:
        global out_vector
        out_vector = out_file.readlines()

    for i in range(len(inp_vector)):
        inp_vector[i] = inp_vector[i][:2]

    for i in range(len(out_vector)):
        out_vector[i] = out_vector[i][:2]

    if not inp_file.closed : inp_file.close()
    if not out_file.closed : out_file.close()

def compare(err):
    iv = 0
    ov = 0
    global serializer_data
    global deserializer_data
    while (iv < len(inp_vector)-5):
        for i in range(0, 20):
            if(i > 0 and i < 17):
                serializer_data.append(inp_vector[iv])
            iv = iv + 1

    while (ov < len(out_vector)-2):
        for o in range(0, 20):
            if(o < 16):
                deserializer_data.append(out_vector[ov])
            ov = ov + 1

    for i in range(len(serializer_data)):
        if (serializer_data[i] != deserializer_data[i]) :
            print('Błąd w linii %d. Serializer: %s Deserializer %s' % (i, serializer_data[i], deserializer_data[i]))
            err = err + 1
    print('Łącznie błędów: %d' % err)
    
inp_vector = []
out_vector = []
serializer_data = []
deserializer_data = []

while (True) :
    errors = 0
    input('Porównać?')
    vect_fill()
    compare(errors)
    print('Serializer: ', serializer_data)
    print('Deserializer: ',deserializer_data)
