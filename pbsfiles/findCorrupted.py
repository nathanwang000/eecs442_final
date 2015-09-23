import glob

corruptedList = []
if __name__ == '__main__':
    for fn in glob.glob('INT*.e*'):
        with open(fn) as f:
            t = f.read()
            if t !='':
                corruptedList.append(fn)
    for f in corruptedList:
        print f
        
