
## paths needed to be modified:
## note that the paths need to be aboslute paths due to the way we are working with Kaldi
DATA_ROOT=$1 # /path/to/speaker_dir/speaker_id
KALDI_ROOT=/home/jb7410/ppg2ppg/kaldi # /path/to/kaldi (the root directory of kaldi you installed) 
PRETRAIN_ROOT=/home/jb7410/ppg2ppg/pretrained_models/pretrained_model # path to pretrained_models/pretrained_model that you donwloaded
SCRIPT_ROOT=/home/jb7410/ppg2ppg/wayne_kaldi_script # path to the directory that contains this script

## shouldn't need to modify anything here
AM_ROOT=$PRETRAIN_ROOT/exp/chain_cleaned/tdnn_1d_sp
IE_ROOT=$PRETRAIN_ROOT/exp/nnet3_cleaned/extractor
LANG_CHAIN_ROOT=$PRETRAIN_ROOT/data/lang_test_tgsmall
BNF_NODE=prefinal-chain.linear

# Call create kaldi files to create all the required kaldi files such as wav.scp
# It also tries to fix the oovs there. It treats each utterance as a separate
# speaker to extract utterance-level ivectors.
python $SCRIPT_ROOT/create_kaldi_files.py $DATA_ROOT

# For the rest of the operations we will do it under kaldi/egs/librispeech/s5
cd $KALDI_ROOT/egs/librispeech/s5 || exit 1;

# Fix kaldi data issues and create spk2utt.
if [ ! -d "$DATA_ROOT/kaldi" ]; then
	          echo "Error: '$DATA_ROOT/kaldi' directory does not exist. Exiting..."
		              exit 1
fi

# echo the current directory
pwd

utils/fix_data_dir.sh $DATA_ROOT/kaldi

# Extract MFCCs, 40-dims, the high resolution one.
steps/make_mfcc.sh --nj 8 --cmd run.pl --compress false \
	--mfcc-config conf/mfcc_hires.conf $DATA_ROOT/kaldi $DATA_ROOT/kaldi/mfcc/log \
	$DATA_ROOT/kaldi/mfcc



#utils/fix_data_dir.sh $DATA_ROOT/kaldi

# Get utterance-level ivectors.
steps/online/nnet2/extract_ivectors.sh --nj 8 --cmd run.pl --compress false \
	        $DATA_ROOT/kaldi $LANG_CHAIN_ROOT $IE_ROOT $DATA_ROOT/kaldi/ivector

# Make BNF.
steps/nnet3/make_bottleneck_features.sh --cmd run.pl --compress false --nj 8 \
	        --use_gpu false --ivector-dir $DATA_ROOT/kaldi/ivector $BNF_NODE \
		        $DATA_ROOT/kaldi $DATA_ROOT/kaldi/bnf $AM_ROOT
