# PowerShell script to run Flutter web with ModelArts configuration

$invokeUrl = "https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/c3ea302b-d98b-4f80-85bb-552e9ca8e0c9"

flutter run -d chrome `
  --dart-define=MODELARTS_PROJECT_ID=59dcb311da5e4ca6b8db8bbc7a7712d7 `
  --dart-define=MODELARTS_ACCESS_KEY=HPUALP3GCEZ2AMWETEHI `
  --dart-define=MODELARTS_SECRET_KEY=ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM `
  --dart-define=MODELARTS_SERVICE_ID=c3ea302b-d98b-4f80-85bb-552e9ca8e0c9 `
  --dart-define=MODELARTS_REGION=ap-southeast-3 `
  --dart-define=MODELARTS_INVOKE_URL=$invokeUrl

