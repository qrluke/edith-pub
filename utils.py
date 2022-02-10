import io
import json
import os
import time


def startup_check(PATH):
    if os.path.exists(PATH) and os.access(PATH, os.R_OK):
        # checks if file exists
        print("File exists and is readable")
    else:
        print("Either file is missing or is not readable, creating file...")
        with io.open(PATH, 'w') as db_file:
            db_file.write(json.dumps({}))


def ctime():
    return int(time.time())
