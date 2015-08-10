import argparse,shlex,os
import collect,collect.package

def process_lstfile(lstfile, context):
    if context.is_lstfile_already_processed(lstfile): return

    with open(lstfile) as f:
        while True:
            line = f.readline()
            if not line: break
            #else
            line = shlex.split(line, True)
            if len(line) == 0: continue
            if line[0] == "$require":
                dirname = os.path.dirname(lstfile)
                required_lstfile = context.apply_variables(line[1])
                if dirname != "": required_lstfile = os.path.normpath(dirname + "/" + required_lstfile)
                process_lstfile(required_lstfile, context)
            elif line[0] == "$package":
                print collect.package.apply(context, line[1:], True)
            elif line[0] == "$copy":
                print os.path.join("files",line[1])
            elif line[0] == "$patch":
                print os.path.join("files",line[2])
            elif line[0] == "$set":
                if len(line) != 3: raise Exception("$set directive gets 2 args")
                context.set_variable(line[1], context.apply_variables(line[2]))
    
    context.mark_lstfile_as_processed(lstfile)
    print lstfile

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=str, default="/", help="source directory")
    parser.add_argument("--var", type=str, action="append", default=[], help="variable")
    parser.add_argument("lstfile", type=str, help=".lst file")
    args = parser.parse_args()

    context = collect.Context(args.source, None, dict(map(lambda x:collect.parse_var(x), args.var)))
    process_lstfile(args.lstfile, context)
