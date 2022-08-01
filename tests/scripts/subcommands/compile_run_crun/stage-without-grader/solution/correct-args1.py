from sys import argv

argc = len(argv)
print("#args={}".format(argc-1))
for i in range(1, argc):
    print("arg[{}]='{}'".format(i, argv[i]))

a, b = [int(x) for x in input().split()]

print(a+b)
