#!/bin/bash

export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim

ANNOT_PATH=/home/soumen/Tensorflow/sign_detection/annotations
EVAL_PATH=/home/soumen/Tensorflow/sign_detection/eval_2
MODEL_PATH=/home/soumen/Tensorflow/sign_detection/output_models/$1/output_inference_graph_v1.pb
CONFIG_PATH=/home/soumen/Tensorflow/sign_detection/eval_metrics
DATA_FILE=$2

python object_detection/inference/infer_detections.py \
  --input_tfrecord_paths=$ANNOT_PATH/$DATA_FILE \
  --output_tfrecord_path=$EVAL_PATH/detections.tfrecord-00000-of-00001 \
  --inference_graph=$MODEL_PATH/frozen_inference_graph.pb \
  --discard_image_pixels


echo "
label_map_path: '$ANNOT_PATH/label_map_text.pbtxt'
tf_record_input_reader: { input_path: '$EVAL_PATH/detections.tfrecord-00000-of-00001' }
" > $CONFIG_PATH/input_config.pbtxt

echo "
metrics_set: 'coco_detection_metrics'
" > $CONFIG_PATH/eval_config.pbtxt

python object_detection/metrics/offline_eval_map_corloc.py \
  --eval_dir=$CONFIG_PATH \
  --eval_config_path=$CONFIG_PATH/eval_config.pbtxt \
  --input_config_path=$CONFIG_PATH/input_config.pbtxt
