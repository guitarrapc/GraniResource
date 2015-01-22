    ディレクトリ: C:\Users\Administrator\DownloadGitHubRawContent


Mode                LastWriteTime     Length Name                                                                                   
----                -------------     ------ ----                                                                                   
-a---        2015/01/22     23:13       1218 localhost.mof                                                                          
詳細: パラメーター ''methodName' = SendConfigurationApply,'className' = MSFT_DSCLocalConfigurationManager,'namespaceName' = root/Microsoft/Windows/DesiredStateConfiguration' を使用して操作 'CimMethod の呼び出し' を実行します。
詳細: コンピューター DSCSERVER、ユーザー SID S-1-5-21-664902234-602511844-991937109-500 から LCM メソッドが呼び出されました。
詳細: [DSCSERVER]: LCM:  [ 開始     設定       ]
詳細: [DSCSERVER]: LCM:  [ 開始     リソース     ]  [[cDownload]hoge]
詳細: [DSCSERVER]: LCM:  [ 開始     テスト      ]  [[cDownload]hoge]
デバッグ: [DSCSERVER]:                            [[cDownload]hoge] Cast uri string 'https://raw.githubusercontent.com/guitarrapc/DSCResources/master/README.md' to System.Uri.
デバッグ: [DSCSERVER]:                            [[cDownload]hoge] Checking Destination Path is existing and Valid as a FileInfo
デバッグ: [DSCSERVER]:                            [[cDownload]hoge] Destination Path found as File : 'C:\Tools\README.md'
デバッグ: [DSCSERVER]:                            [[cDownload]hoge] Matching FileHash to verify file is already exist/Up-To-Date or not.
デバッグ: [DSCSERVER]:                            [[cDownload]hoge] File found from DestinationPath. Checking already up-to-date.
デバッグ: [DSCSERVER]:                            [[cDownload]hoge] CurrentFileHash : CachedFileHash -> F53C273BFC27562EA94E39D66B4360B899349D6E81B8BD26B78DF915923A831D :
詳細: [DSCSERVER]:                            [[cDownload]hoge] Current DestinationPath FileHash and Cache FileHash not matched. Need to download latest file.
詳細: [DSCSERVER]: LCM:  [ 終了     テスト      ]  [[cDownload]hoge]  0.0160 秒かかりました。
詳細: [DSCSERVER]: LCM:  [ 開始     設定       ]  [[cDownload]hoge]
デバッグ: [DSCSERVER]:                            [[cDownload]hoge] Cast uri string 'https://raw.githubusercontent.com/guitarrapc/DSCResources/master/README.md' to System.Uri.
デバッグ: [DSCSERVER]:                            [[cDownload]hoge] Check DestinationPath 'C:\Tools\README.md' is FileInfo and Parent Dir
ectory already exist.
デバッグ: [DSCSERVER]:                            [[cDownload]hoge] Adding Keep-Alive as true to the Request Header.
デバッグ: [DSCSERVER]:                            [[cDownload]hoge] Adding ContentType : 'application/json'
デバッグ: [DSCSERVER]:                            [[cDownload]hoge] Adding UserAgent : 'Mozilla/5.0 (Windows NT; Windows NT 6.3; en-US) WindowsPowerShell/4.0'
デバッグ: [DSCSERVER]:                            [[cDownload]hoge] Testing connection to the uri : https://raw.githubusercontent.com/guitarrapc/DSCResources/master/README.md
詳細: [DSCSERVER]:                            [[cDownload]hoge] Status Code returns '200'. Start download stream from uri : 'https://raw.githubusercontent.com/guitarrapc/DSCResources/master/README.md'
デバッグ: [DSCSERVER]:                            [[cDownload]hoge] Start writing downloaded stream to File Path : 'C:\Tools\README.md'
デバッグ: [DSCSERVER]:                            [[cDownload]hoge] Download content complete.
デバッグ: [DSCSERVER]:                            [[cDownload]hoge] Updating cache path 'C:\ProgramData\Microsoft\Windows\PowerShell\Configuration\CustomProvCache\Grani_Download\-448662428' for current Filehash SHA256 'F53C273BFC27562EA94E39D66B4360B899349D6E81B8BD26B78
DF915923A831D'.
詳細: [DSCSERVER]: LCM:  [ 終了     設定       ]  [[cDownload]hoge]  0.2660 秒かかりました。
詳細: [DSCSERVER]: LCM:  [ 終了     リソース     ]  [[cDownload]hoge]
詳細: [DSCSERVER]: LCM:  [ 終了     設定       ]
詳細: [DSCSERVER]: LCM:  [ 終了     設定       ]    (0.3280 秒)。
詳細: 操作 'CimMethod の呼び出し' が完了しました。
詳細: 構成ジョブが完了するまでにかかった時間は 0.341 秒です