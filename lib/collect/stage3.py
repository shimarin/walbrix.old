import argparse,os,subprocess
import collect,find_latest_stage3

def apply(context, args):
    parser = argparse.ArgumentParser()
    parser.add_argument("-b", "--baseurl", help="Base URL which points gentoo mirror", default="http://ftp.kddilabs.jp/pub/Linux/distributions/gentoo")
    args = parser.parse_args(args)
    url = find_latest_stage3.run(context.get_variable("ARCH"), context.apply_variables(args.baseurl))
    filename = os.path.basename(url)
    cache_file = "download_cache/%s" % filename
    progress_file = "download_cache/_download_in_progress"
    if not os.path.exists(cache_file):
        collect.mkdir_p("download_cache")
        subprocess.check_call(["wget","-O",progress_file,url])
        os.rename(progress_file, cache_file)

    subprocess.check_call(["tar","jxvpf",cache_file,"-C",context.destination])

