import sys
from collections import OrderedDict

def prepareInput(matrixIn, indiF ,fastIndepIn):
    indiList = []
    sampleDict = {}
    with open(indiF) as source:
        for line in source:
            line = line.rstrip().split()
            indiList.append(line[0])
    header = 0
    with open(matrixIn) as source:
        for line in source:
            if header == 0:
                header += 1
            else:
                line = line.split()
                if line[0] not in sampleDict:
                    sampleDict[line[0]] = ["0"] * len(indiList)
                    sampleDict[line[0]][indiList.index(line[0])] = "10000"
                if line[1] not in sampleDict:
                    sampleDict[line[1]] = ["0"] * len(indiList)
                    sampleDict[line[1]][indiList.index(line[1])] = "10000"
                sampleDict[line[0]][indiList.index(line[1])] = str(line[2])
                sampleDict[line[1]][indiList.index(line[0])] = str(line[2])
    with open(fastIndepIn, "w") as dest:
        dest.write(" "+" ".join(indiList)+"\n")
        for indi in indiList:
            dest.write(indi+" "+" ".join(sampleDict[indi])+"\n")

if __name__ == "__main__":
    prepareInput(sys.argv[1], sys.argv[2], sys.argv[3])
