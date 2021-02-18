from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import argparse
import tensorflow as tf
import pandas as pd
import numpy as np
import shutil
import os

tf.logging.set_verbosity(tf.logging.INFO)

BLE_RSSI = pd.read_csv('/opt/iBeacon_RSSI_Labeled.csv') #Labeled dataset

# Configure model options
TF_DATA_DIR = os.getenv("TF_DATA_DIR", "/tmp/data/")
TF_MODEL_DIR = os.getenv("TF_MODEL_DIR", "/mnt/")
TF_EXPORT_DIR = os.getenv("TF_EXPORT_DIR", "/mnt/")
TF_MODEL_TYPE = os.getenv("TF_MODEL_TYPE", "DNN")
TF_TRAIN_STEPS = int(os.getenv("TF_TRAIN_STEPS", 5000))
TF_BATCH_SIZE = int(os.getenv("TF_BATCH_SIZE", 50))
TF_LEARNING_RATE = float(os.getenv("TF_LEARNING_RATE", 0.001))


# Feature columns
COLUMNS = list(BLE_RSSI.columns)
FEATURES = COLUMNS[2:]
def make_feature_cols():
  input_columns = [tf.feature_column.numeric_column(k) for k in FEATURES]
  return input_columns

feature_columns =  make_feature_cols()
feature_spec = tf.feature_column.make_parse_example_spec(feature_columns)

serving_input_receiver_fn = tf.estimator.export.build_parsing_serving_input_receiver_fn(feature_spec)
INPUT_FEATURE = 'x'
NUM_CLASSES = 3

def main(unused_args):

    b3001 = tf.feature_column.numeric_column(key='b3001',dtype=tf.float64)
    b3002 = tf.feature_column.numeric_column(key='b3002',dtype=tf.float64)
    b3003 = tf.feature_column.numeric_column(key='b3003',dtype=tf.float64)
    b3004 = tf.feature_column.numeric_column(key='b3004',dtype=tf.float64)
    b3005 = tf.feature_column.numeric_column(key='b3005',dtype=tf.float64)
    b3006 = tf.feature_column.numeric_column(key='b3006',dtype=tf.float64)
    b3007 = tf.feature_column.numeric_column(key='b3007',dtype=tf.float64)
    b3008 = tf.feature_column.numeric_column(key='b3008',dtype=tf.float64)
    b3009 = tf.feature_column.numeric_column(key='b3009',dtype=tf.float64)
    b3010 = tf.feature_column.numeric_column(key='b3010',dtype=tf.float64)
    b3011 = tf.feature_column.numeric_column(key='b3011',dtype=tf.float64)
    b3012 = tf.feature_column.numeric_column(key='b3012',dtype=tf.float64)
    b3013 = tf.feature_column.numeric_column(key='b3013',dtype=tf.float64)
    feature_columns = [b3001, b3002, b3003, b3004, b3005, b3006, b3007, b3008, b3009, b3010, b3011, b3012, b3013]

    df_full = pd.read_csv('/opt/iBeacon_RSSI_Labeled.csv') #Labeled dataset

    # Input Data Preprocessing
    df_full = df_full.drop(['date'],axis = 1)
    df_full[FEATURES] = (df_full[FEATURES])/(-200)

    #Output Data Preprocessing
    dict = {'O02': 0,'P01': 1,'P02': 2,'R01': 3,'R02': 4,'S01': 5,'S02': 6,'T01': 7,'U02': 8,'U01': 9,'J03': 10,'K03': 11,'L03': 12,'M03': 13,'N03': 14,'O03': 15,'P03': 16,'Q03': 17,'R03': 18,'S03': 19,'T03': 20,'U03': 21,'U04': 22,'T04': 23,'S04': 24,'R04': 25,'Q04': 26,'P04': 27,'O04': 28,'N04': 29,'M04': 30,'L04': 31,'K04': 32,'J04': 33,'I04': 34,'I05': 35,'J05': 36,'K05': 37,'L05': 38,'M05': 39,'N05': 40,'O05': 41,'P05': 42,'Q05': 43,'R05': 44,'S05': 45,'T05': 46,'U05': 47,'S06': 48,'R06': 49,'Q06': 50,'P06': 51,'O06': 52,'N06': 53,'M06': 54,'L06': 55,'K06': 56,'J06': 57,'I06': 58,'F08': 59,'J02': 60,'J07': 61,'I07': 62,'I10': 63,'J10': 64,'D15': 65,'E15': 66,'G15': 67,'J15': 68,'L15': 69,'R15': 70,'T15': 71,'W15': 72,'I08': 73,'I03': 74,'J08': 75,'I01': 76,'I02': 77,'J01': 78,'K01': 79,'K02': 80,'L01': 81,'L02': 82,'M01': 83,'M02': 84,'N01': 85,'N02': 86,'O01': 87,'I09': 88,'D14': 89,'D13': 90,'K07': 91,'K08': 92,'N15': 93,'P15': 94,'I15': 95,'S15': 96,'U15': 97,'V15': 98,'S07': 99,'S08': 100,'L09': 101,'L08': 102,'Q02': 103,'Q01': 104}

    df_full['location'] = df_full['location'].map(dict)
    df_train=df_full.sample(frac=0.8,random_state=200)
    df_valid=df_full.drop(df_train.index)

    location_counts = BLE_RSSI.location.value_counts()
    x1 = np.asarray(df_train[FEATURES])
    y1 = np.asarray(df_train['location'])

    x2 = np.asarray(df_valid[FEATURES])
    y2 = np.asarray(df_valid['location'])

    def formatFeatures(features):
        formattedFeatures = {}
        numColumns = features.shape[1]

        for i in range(0, numColumns):
            formattedFeatures["b"+str(3001+i)] = features[:, i]
        return formattedFeatures

    trainingFeatures = formatFeatures(x1)
    trainingCategories = y1

    testFeatures = formatFeatures(x2)
    testCategories = y2

    # Train Input Function
    def train_input_fn():
        dataset = tf.data.Dataset.from_tensor_slices((trainingFeatures, y1))
        dataset = dataset.repeat(FLAGS.epochs).batch(FLAGS.batch_size)
        return dataset

    # Test Input Function
    def eval_input_fn():
        dataset = tf.data.Dataset.from_tensor_slices((testFeatures, y2))
        return dataset.repeat(FLAGS.epochs).batch(FLAGS.batch_size)


    config = tf.estimator.RunConfig(model_dir=FLAGS.tf_model_dir, save_summary_steps=100, save_checkpoints_steps=100)

    # Build 3 layer DNN classifier
    model = tf.estimator.DNNClassifier(hidden_units = [13,65,110],
                 feature_columns = feature_columns,
                 optimizer=tf.train.AdamOptimizer(learning_rate=FLAGS.learning_rate, beta1=FLAGS.beta1, beta2=FLAGS.beta2),
                 model_dir = FLAGS.tf_model_dir,
                 n_classes=105, config=config
               )

    export_final = tf.estimator.FinalExporter(FLAGS.tf_export_dir, serving_input_receiver_fn=serving_input_receiver_fn)

    train_spec = tf.estimator.TrainSpec(input_fn=train_input_fn,
                                    max_steps=FLAGS.tf_train_steps)

    eval_spec = tf.estimator.EvalSpec(input_fn=eval_input_fn,
                                  steps=100,
                                  exporters=export_final,
                                  throttle_secs=1,
                                  start_delay_secs=1)

    # Train and Evaluate the model
    tf.estimator.train_and_evaluate(model, train_spec, eval_spec)

if __name__ == "__main__":
  parser = argparse.ArgumentParser()

  parser.add_argument('--tf-model-dir',
                      type=str,
                      default='/mnt/',
                      help='GCS path or local directory.')
  parser.add_argument('--tf-export-dir',
                      type=str,
                      default='/mnt/',
                      help='GCS path or local directory to export model')
  parser.add_argument('--tf-model-type',
                      type=str,
                      default='DNN',
                      help='Tensorflow model type for training.')
  parser.add_argument('--tf-train-steps',
                      type=int,
                      default=5000,
                      help='The number of training steps to perform.')
  parser.add_argument('--batch-size',
                      type=int,
                      default=128,
                      help='The number of batch size during training')
  parser.add_argument('--epochs',
                      type=int,
                      default=1000,
                      help='The number of times repeat during training')
  parser.add_argument('--learning-rate',
                      type=float,
                      default=0.001,
                      help='Initial learning rate')
  parser.add_argument('--beta1', type=float, default=0.1,
                      help='Initial learning rate')
  parser.add_argument('--beta2', type=float, default=0.5,
                      help='Initial learning rate')
  FLAGS, unparsed = parser.parse_known_args()
  tf.app.run()
