import glob

corruptedList = []
if __name__ == '__main__':
    for fn in glob.glob('RFtr*.e*'):
        with open(fn) as f:
            t = f.read()
            if t !='':
                corruptedList.append(fn)
    for fn in glob.glob('RFte*.e*'):
        with open(fn) as f:
            t = f.read()
            if t !='':
                corruptedList.append(fn)

    for f in corruptedList:
        print f
        
