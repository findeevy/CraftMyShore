#Things to do: make game export water data, stacking, etc
print("Welcome to the Craft My Coast Analyzer")
print("\nLoading previous games...")
with open("previousGame.dat", "r") as f:
    data = f.readlines()
    print(data)
    [i.translate('[]') for i in data]
    print(data)
    print("Average Amount of Towns Saved: "+str(str(data).count("2")/len(data)))
    print("Average Amount of Vegetation Planted: "+str(str(data).count("4")/len(data)))
    #print("Average Position of Surviving Town:" + findAverageY)


def findAverageY():
    pass

