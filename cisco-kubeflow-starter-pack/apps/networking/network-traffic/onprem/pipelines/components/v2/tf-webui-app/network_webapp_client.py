import os
import random
import numpy
import pandas as pd
import tensorflow as tf
import grpc
from tensorflow_serving.apis import predict_pb2
from tensorflow_serving.apis import prediction_service_pb2
from tensorflow_serving.apis import classification_pb2
from tensorflow_serving.apis import regression_pb2
from grpc.beta import implementations
from tensorflow_serving.apis import predict_pb2
from tensorflow_serving.apis import prediction_service_pb2_grpc
from tensorflow_serving.apis import classification_pb2
from sklearn.preprocessing import LabelEncoder,MinMaxScaler
from flask import Flask,render_template, request

app = Flask(__name__)
app.config["UPLOAD_FOLDER"]=os.getcwd()
TF_MODEL_SERVER_HOST = os.getenv("TF_MODEL_SERVER_HOST", "127.0.0.1")
TF_MODEL_SERVER_PORT = int(os.getenv("TF_MODEL_SERVER_PORT", 9000))
#server="10.111.238.238:9000"
server = str(TF_MODEL_SERVER_HOST)+":"+str(TF_MODEL_SERVER_PORT)
channel = grpc.insecure_channel(server)
stub = prediction_service_pb2_grpc.PredictionServiceStub(channel)

request = classification_pb2.ClassificationRequest()
request.model_spec.name = 'Model_Network'
request.model_spec.signature_name = 'serving_default'
try :

    response = stub.Classify(request, 10.0)
except Exception as e:
    pass

server = str(TF_MODEL_SERVER_HOST)+":"+str(TF_MODEL_SERVER_PORT)
print(server)

label_dict = {'Benign':0,'Bot':1}

lstPred_col = ['BwdIATMean', 'BwdIATTot', 'BwdPktLenMax', 'BwdPktLenMean', 'FlowDuration', 'FlowIATMean', 'FlowIATStd', 'FwdPSHFlags', 'FwdSegSizeMin', 'InitBwdWinByts']

def get_key(val):
    for key, value in label_dict.items():
        if val == value:
            return key

@app.route('/')
def form():
  return render_template("login.html")

@app.route('/transform', methods=['POST'])
def transform_view():
    from flask import request
    csv = request.files['file']
    csv.save("Network_Test_Traffic.csv")
    chunksize = 23
    chunk_list = []
    missing_values = ["n/a", "na", "--", "Infinity", "infinity", "Nan", "NaN"]

    for chunk in pd.read_csv("Network_Test_Traffic.csv", chunksize=chunksize, na_values=missing_values):
        chunk_list.append(chunk)
        break
    dataFrme = pd.concat(chunk_list)

    lstcols = []
    for i in dataFrme.columns:
        i = str(i).replace(' ', '').replace('/', '')
        lstcols.append(i)
    dataFrme.columns = lstcols
    dataFrme = dataFrme[lstPred_col]
    df_predict_original = dataFrme.copy()
    scaler = MinMaxScaler(feature_range=(0, 1))
    selected_X = pd.DataFrame(scaler.fit_transform(dataFrme), columns=dataFrme.columns, index=dataFrme.index)
    df_predict1 = selected_X.copy()

    max_rows = 2800
    dataframes = []
    dataframes_original = []
    while len(df_predict1) > max_rows:
        top_original = df_predict_original[:max_rows]
        top = df_predict1[:max_rows]
        dataframes.append(top)
        dataframes_original.append(top_original)
        df_predict1 = df_predict1[max_rows:]
        df_predict_original = df_predict_original[max_rows:]
    else:
        dataframes.append(df_predict1)
        dataframes_original.append(df_predict_original)

    final_df = pd.DataFrame(columns=lstPred_col)
    for i, j in zip(dataframes, dataframes_original):
        j.index = pd.RangeIndex(len(i.index))
        j.index = range(len(i.index))
        examples = []
        for index, row in i.iterrows():
            example = tf.train.Example()
            for col, value in row.iteritems():
                example.features.feature[col].float_list.value.append(value)
            examples.append(example)

    channel = grpc.insecure_channel(server)
    stub = prediction_service_pb2_grpc.PredictionServiceStub(channel)
    request = classification_pb2.ClassificationRequest()
    request.model_spec.name = 'Model_Network'
    request.model_spec.signature_name = 'serving_default'
    request.input.example_list.examples.extend(examples)
    response = stub.Classify(request, 10.0)


    testdata = df_predict1[lstPred_col]
    outputs = testdata.copy()
    for index, row in outputs.iterrows():
        max_class = max(response.result.classifications[index].classes, key=lambda c: c.score)
        outputs.loc[index, 'Location'] = get_key(int(max_class.label))
        outputs.loc[index, 'Probability'] = max_class.score
    print(outputs)

    final_df = pd.DataFrame(
        columns=['BwdIATMean', 'BwdIATTot', 'BwdPktLenMax', 'BwdPktLenMean', 'FlowDuration', 'FlowIATMean',
                 'FlowIATStd', 'FwdPSHFlags', 'FwdSegSizeMin', 'InitBwdWinByts', 'Location', 'Probability'])
    final_df = final_df.append(outputs, ignore_index=True)

    os.remove("Network_Test_Traffic.csv")
    return render_template('view.html', tables=[final_df.to_html()], titles=['na'])


if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=80, threaded=True)

