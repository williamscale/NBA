import py7zr
import json
import pickle

def unzip_7z(source_path, destination_path):

	with py7zr.SevenZipFile(source_path, mode = "r") as zipped_file:
	    zipped_file.extractall(destination_path)

# unzip_7z(
# 	source_path = "./Data/Zipped/01.02.2016.HOU.at.SAS.7z",
# 	destination_path = "./Data/Games/"
# 	)


f = open('./Data/Games/0021500502.json')
data = json.load(f)

events = data["events"]
print(events)

f.close()

# print(len(events))
# print(events[0].keys())
# print(events[0]["moments"])