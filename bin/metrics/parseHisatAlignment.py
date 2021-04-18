import re,sys


# Match the speciesname
namePat=re.compile("\s+wildcards:.*name=([\w_\d]+),")

# Match the overall alignment
alnPat=re.compile("([\d.]+)% overall alignment rate")

# Match the SRA name
samPat=re.compile("Writing to (\w+\d+).sam")


def parseFile(fn,p): # match one pattern for whole file
  f = open(fn).read()
  m = re.findall(p,f)
  if(len(m)==1):
    return m[0]
  else:
    return "re %s did not match" % str(p)

if(__name__=="__main__"):
  fns = sys.argv[1:]
  print("{:<20}{:<20}{:<20}".format("Species","SRA","Alignment"))
  for f in fns:
    name = parseFile(f,namePat)
    aln = parseFile(f,alnPat)
    sam = parseFile(f,samPat)
    print(("{:<20}"*3).format(name,sam,aln))
