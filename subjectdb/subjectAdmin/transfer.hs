

import System.FilePath
import Data.List.Split
import Data.Text.IO (readFile)


            stuff <- liftIO $ do
                let log = "log.txt"
                void $ rawSystem matlab32 ["-nodesktop", "-nosplash", "-wait", "-logfile", log, "-sd", matlabDir, "-r", "setupEnvironment,collectInfo,quit"]
                lg <- readFile $ matlabDir </> log
                return . splitOn "\n" $ T.unpack lg


matlabDir = "C:\\Users\\nlab\\Desktop\\ratrix\\bootstrap"
matlab32  = "C:\\Program Files (x86)\\MATLAB\\R2011b\\bin\\matlab.exe"
