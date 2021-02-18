import kfp

if __name__ == '__main__':
    kfp_client = kfp.Client()
    kfp_client.create_run_from_pipeline_package(pipeline_file='blerssi_formatted.yaml', arguments=None, run_name="blerssi-test", experiment_name="blerssi-test")
