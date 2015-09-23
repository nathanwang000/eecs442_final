if __name__ == '__main__':
    action = range(1,601)
    start = action[::12]
    end = map(lambda x: x+11, start)
    
    zerofiles = set()
    with open('zero_size.txt') as f:
        for l in f:
            l = l[2:l.find('.e')]
            zerofiles.add(l)

    for s,e in zip(start, end):
        filename = 'test_RF_%d_%d' % (s,e)
        if filename not in zerofiles:
            print "%s is probabily wrong" % filename
    print "done"


