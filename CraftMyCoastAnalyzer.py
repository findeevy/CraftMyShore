print("Welcome to the Craft My Coast Analyzer")
print("\nLoading previous games...")
with open("previousGame.dat", "r") as f:
    data = f.readlines()
    print(data)
    print("Average Amount of Towns Saved: "+str(str(data).count("2")))
