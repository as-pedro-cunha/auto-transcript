# this script should read all the files in ../output and transcribe them using multiple threads
import whisper
import sys

file = sys.argv[1]

# run whisper on the file
model = whisper.load_model("large-v3")
result = model.transcribe(file, language="pt")
# write result to file with the same name as the input file but with .txt extension
with open(file[:-4] + ".txt", "w") as f:
    f.write(result["text"])


