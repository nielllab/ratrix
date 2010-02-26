function out=cosyne2010(stimType,data)
% these are the cells picked out for cosyne 2010.  note that tmpAnalysis enforces an additional restriction that data.mins>=5

out=false;
switch stimType
    case 'gaussian' %14 total
        switch data.ratID
            case '164'
                %9	49.0 mins	164-03.13.09-z17.62-chunk1-code1-1dde0e88c83352d9790baa30af013905e63a48e7/gaussian-t1202.274-4140.2955
                if strcmp(data.date,'03.13.09') && strcmp(data.hash,'1dde0e88c83352d9790baa30af013905e63a48e7') && data.z==17.62 && strcmp(data.chunkNum,'1')
                    out=true; end
                
                %10	32.3 mins	164-03.17.09-z9.255-chunk1-code1-3b43c16b7b96f501204aa3bca54bd522856d2320/gaussian-t964.331-2903.654
                %11	13.6 mins	164-03.17.09-z8.58-chunk1-code1-f2bf60d0a7dd03eb10ec24d6620d82cb05a63d90/gaussian-t1592.508-2409.56
                %12	12.1 mins	164-03.17.09-z8.58-chunk3-code1-f2bf60d0a7dd03eb10ec24d6620d82cb05a63d90/gaussian-t2409.56-3133
                if strcmp(data.date,'03.17.09') && ismember(data.hash,{'f2bf60d0a7dd03eb10ec24d6620d82cb05a63d90','3b43c16b7b96f501204aa3bca54bd522856d2320'}) && any(data.z==[9.255 8.58]) && ismember(data.chunkNum,{'1','3'})
                    out=true; end
                
                %13	5.7 mins	164-03.19.09-z8.255-chunk1-code1-60085edf1083730b0fd41d344ebfa927c0b73863/gaussian-t488.415-829
                if strcmp(data.date,'03.19.09') && strcmp(data.hash,'60085edf1083730b0fd41d344ebfa927c0b73863') && data.z==8.255 && strcmp(data.chunkNum,'1')
                    out=true; end
                
                %15	30.3 mins	164-03.25.09-z18.55-chunk1-code1-fd0540a23f6a44ae778fdc547bb870bf9bd1f5e0/gaussian-t335.022-2154.425
                if strcmp(data.date,'03.25.09') && strcmp(data.hash,'fd0540a23f6a44ae778fdc547bb870bf9bd1f5e0') && data.z==18.55 && strcmp(data.chunkNum,'1')
                    out=true; end
                
                %16	9.6 mins	164-03.25.09-z19.2-chunk1-code1-d6ed451b974604f67bca8bb76c3b4cba6d6bdb67/gaussian-t998.45-1576
                %17	24.6 mins	164-03.25.09-z19.2-chunk1-code1-9d10d71ac6e4d1de0f7a8d88ca27b72790f9553d/gaussian-t1670-3144.317
                %18	117.5 mins	164-03.25.09-z19.2-chunk1-code1-9d10d71ac6e4d1de0f7a8d88ca27b72790f9553d/gaussian-t5861.42-12912
                %19	14.6 mins	164-03.25.09-z19.2-chunk1-code1-c7b84a4cc5df11db1aedcccf4c12f85dace99275/gaussian-t0-875
                if strcmp(data.date,'03.25.09') && ismember(data.hash,{'c7b84a4cc5df11db1aedcccf4c12f85dace99275','9d10d71ac6e4d1de0f7a8d88ca27b72790f9553d','d6ed451b974604f67bca8bb76c3b4cba6d6bdb67'}) && data.z==19.2 && strcmp(data.chunkNum,'1')
                    out=true; end
                
                %21	13.2 mins	164-04.07.09-z7.76-chunk2-code1-891c8c7f8286129461df5aa06b799ead54d28176/gaussian-t1480-2270.726
                if strcmp(data.date,'04.07.09') && strcmp(data.hash,'891c8c7f8286129461df5aa06b799ead54d28176') && data.z==7.76 && strcmp(data.chunkNum,'2')
                    out=true; end
                
                %22	43.3 mins	164-04.15.09-z47.34-chunk1-code1-acf4f35b54186cd6055697b58718da28e7b2bf80/gaussian-t2042.385-4641
                if strcmp(data.date,'04.15.09') && strcmp(data.hash,'acf4f35b54186cd6055697b58718da28e7b2bf80') && data.z==47.34 && strcmp(data.chunkNum,'1')
                    out=true; end
                
                %23	17.5 mins	164-04.17.09-z47.88-chunk2-code1-89493235e157403e6bad4b39b63b1c6234ea45dd/gaussian-t3891.4-4941
                if strcmp(data.date,'04.17.09') && strcmp(data.hash,'89493235e157403e6bad4b39b63b1c6234ea45dd') && data.z==47.88 && strcmp(data.chunkNum,'2')
                    out=true; end
                
            case '188'
                %(interneuron?)
                %27	55.7 mins	188-04.24.09-z52.48-chunk1-code1-9196f9c63cf78cac462dac2cedd55306961b7fd0/gaussian-t5554.8235-8895.053
                if strcmp(data.date,'04.24.09') && strcmp(data.hash,'9196f9c63cf78cac462dac2cedd55306961b7fd0') && data.z==52.48 && strcmp(data.chunkNum,'1')
                    out=true; end
            otherwise
        end
    case 'hateren' %6 total
        switch data.ratID
            case '164'
                %1	68.6 mins	164-03.13.09-z17.62-chunk1-code1-1dde0e88c83352d9790baa30af013905e63a48e7/hateren-t4159.88-8276
                if strcmp(data.date,'03.13.09') && strcmp(data.hash,'1dde0e88c83352d9790baa30af013905e63a48e7') && data.z==17.62 && strcmp(data.chunkNum,'1')
                    out=true; end
                
                %6	33.5 mins	164-04.15.09-z47.34-chunk1-code1-acf4f35b54186cd6055697b58718da28e7b2bf80/hateren-t0.001-2012.453
                if strcmp(data.date,'04.15.09') && strcmp(data.hash,'acf4f35b54186cd6055697b58718da28e7b2bf80') && data.z==47.34 && strcmp(data.chunkNum,'1')
                    out=true; end
                
            case '188'
                %9	53.4 mins	188-04.23.09-z38.885-chunk3-code1-4b45921ce9ef4421aa984128a39f2203b8f9a381/hateren-t5951.891-9156
                if strcmp(data.date,'04.23.09') && strcmp(data.hash,'4b45921ce9ef4421aa984128a39f2203b8f9a381') && data.z==38.885 && strcmp(data.chunkNum,'3')
                    out=true; end
                
                %11	35.9 mins	188-04.23.09-z38.26-chunk5-code3-4b45921ce9ef4421aa984128a39f2203b8f9a381/hateren-t10123-12278
                if strcmp(data.date,'04.23.09') && strcmp(data.hash,'4b45921ce9ef4421aa984128a39f2203b8f9a381') && data.z==38.26 && strcmp(data.chunkNum,'5')
                    out=true; end
                
                %15	110.1 mins	188-04.29.09-z27.83-chunk1-code1-c298e72f2ac2edbe8c043c41e72ebc6432394504/hateren-t4854.675-11463
                if strcmp(data.date,'04.29.09') && strcmp(data.hash,'c298e72f2ac2edbe8c043c41e72ebc6432394504') && data.z==27.83 && strcmp(data.chunkNum,'1')
                    out=true; end
                
                %16	66.4 mins	188-05.06.09-z28.04-chunk1-code1-e8b33f5945b56d2bb55c8c098a1d72de73206822/hateren-t3680.88-7664
                if strcmp(data.date,'05.06.09') && strcmp(data.hash,'e8b33f5945b56d2bb55c8c098a1d72de73206822') && data.z==28.04 && strcmp(data.chunkNum,'1')
                    out=true; end
            otherwise
        end
    otherwise
end
out = strcmp(data.ratID,'164') && strcmp(stimType,'gaussian') && strcmp(data.date,'03.17.09') && ismember(data.hash,{'f2bf60d0a7dd03eb10ec24d6620d82cb05a63d90'}) && data.z==8.58 && ismember(data.chunkNum,{'1'});

end