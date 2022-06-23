import argparse
import numpy as np
import time
from matplotlib import pyplot as plt
import pandas as pd
import gnuradio
import uhd

def parse_args():
    """Parse the command line arguments"""
    parser = argparse.ArgumentParser()
    parser.add_argument("-a", "--args", default="", type=str)
    parser.add_argument("-o", "--output-file", default="./new_out.csv", type=str, required=False)
    parser.add_argument("-f", "--freq", type=float, required=False)
    parser.add_argument("-r", "--rate", default=1e6, type=float)
    parser.add_argument("-d", "--duration", default=1/58.0, type=float)
    parser.add_argument("-c", "--channels", default=0, nargs="+", type=int)
    parser.add_argument("-g", "--gain", type=int, default=10)
    parser.add_argument("-n", "--numpy", default=False, action="store_true",
                        help="Save output file in NumPy format (default: No)")
    return parser.parse_args()

def main():
    """RX samples and write to file"""
    args = parse_args()
    usrp = uhd.usrp.MultiUSRP(args.args)
    num_samps = int(np.ceil(args.duration*args.rate))
    print(num_samps)
    data = np.ones((16667, 59))
    
    columns =[]
    i = 100
    while i<= 3000:
        columns.append(str(i)+"MHz")
        i=i+50

    dataframe = pd.DataFrame(columns=columns)
    complete_dataframe = []
    
    if not isinstance(args.channels, list):
        args.channels = [args.channels]

    a = 10
    while a>=0:
        freq = 100e6
      
        i = 100
        col = ""
        while freq <= 3.0e9:
            col = str(i)+"MHz"
            t = time.time()        
            samps = usrp.recv_num_samps(num_samps, freq, args.rate, args.channels, args.gain)
            dataframe[col]=samps[0]
            t = t-time.time()
            print("printing for freqeuncy: ",freq," ", samps)
            freq=freq+50.0e6
            i=i+50
        a=a-1
        complete_dataframe.append(dataframe) 
    dataframe_to_csv = pd.concat(complete_dataframe)
    print(dataframe_to_csv.head())
    print(dataframe_to_csv.shape)
    print(dataframe_to_csv.size)
    
    dataframe_to_csv.to_csv('./10_data_csv.csv')
    #     plt.plot(a[0])
    #     plt.show()
    # with open(args.output_file, 'wb') as out_file:
    #     if args.numpy:
    #         np.save(out_file, samps, allow_pickle=False, fix_imports=False)
    #     else:
    #         samps.tofile(out_file)

if __name__ == "__main__":
    
    main()
