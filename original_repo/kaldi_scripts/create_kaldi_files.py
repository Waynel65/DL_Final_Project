import glob
import os
import sys

def fix_oov(line: str):
    oov_dict = {
        "'EM": "EM",
        "MCVEIGH": "MC VEIGH",
        "MCFEE'S": "MC FEE'S",
        "DENNIN'S": "DENNING'S",
        "DAUGHTRY'S": "DAW TREE'S",
        "DAUGHTRY": "DAW TREE"
    }
    line_split = line.split()
    for idx, word in enumerate(line_split):
        if word in oov_dict:
            print('Changing OOV {} to {}'.format(word, oov_dict[word]))
            line_split[idx] = oov_dict[word]
    return ' '.join(line_split)

if __name__ == '__main__':
    cache_folder = sys.argv[1]
    output_dir = os.path.join(cache_folder, 'kaldi')
    if not os.path.exists(output_dir):
        os.mkdir(output_dir)
    speaker_id = os.path.basename(cache_folder)
    wav_file_paths = glob.glob(os.path.join(cache_folder, 'wav/*.wav'))
    wav_file_paths.sort()

    try:
        with open(os.path.join(output_dir, 'wav.scp'), 'w') as wav_scp, \
             open(os.path.join(output_dir, 'utt2spk'), 'w') as utt2spk, \
             open(os.path.join(output_dir, 'text'), 'w') as text:

            for ii, each_wav in enumerate(wav_file_paths):
                line_break = '\n'
                if ii + 1 == len(wav_file_paths):
                    line_break = ''

                wav_file_name = os.path.basename(each_wav)
                wav_file_id = wav_file_name.split('.')[0]
                utt_id = '{}_{}'.format(speaker_id, wav_file_id)
                wav_scp.write('{} {}{}'.format(utt_id, each_wav, line_break))
                utt2spk.write('{} {}{}'.format(utt_id, utt_id, line_break))
    except IOError as e:
        print(f"Error: Unable to write to file: {e}")
        sys.exit(1)

    print("python script done running")