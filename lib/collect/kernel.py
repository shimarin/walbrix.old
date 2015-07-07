import os
import kernelver

def apply(context, args):
    if len(args) != 1: raise Exception("$kernel directive gets 1 argument")
    kernelfile = os.path.normpath("%s/%s" % (context.source, context.apply_variables(args[0])))
    print("Getting KERNEL_VERSION from %s" % kernelfile)
    kernel_version = kernelver.get_kernel_version_string(kernelfile)
    context.set_variable("KERNEL_VERSION", kernel_version)
    print("KERNEL_VERSION set to %s" % kernel_version)
