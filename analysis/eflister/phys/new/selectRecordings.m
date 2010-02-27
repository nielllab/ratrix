function out=selectRecordings(selection,stimType,data)
%change this to emit a cell ID so recordings can be combined

out = data.mins>=5;
if out
    switch selection
        case 'gauss'
            switch stimType % 14
                
                case {'gaussian','gaussgrass','rpt/unq'}
                
                out = any([...
                    
                %here are the proposed cell groupings from committee mtg 2010
                
                %%% gaussian
                
                % bad crt artifacts
                %1	6.3 mins	164-10.21.08-z14.34-chunk3-code0-7877f102598baece5bd3a79ec76311f0ff33befa/gaussian-t6840.385-7220
                %2	7.7 mins	164-10.21.08-z14.34-chunk1-code0-7877f102598baece5bd3a79ec76311f0ff33befa/gaussian-t7515-7975
                %3	5.1 mins	164-10.22.08-z15.02-chunk2-code2-05c3a782d1902bb79db2e6d92d0c2ea33022a147/gaussian-t1094.44-1403.028
                
                %
                %4	6.6 mins	164-10.22.08-z15.02-chunk1-code2-05c3a782d1902bb79db2e6d92d0c2ea33022a147/gaussian-t1435.8-1833.25
                verify(data,'164','10.22.08','05c3a782d1902bb79db2e6d92d0c2ea33022a147','1',15.02)...
                
                %
                %5	5.3 mins	164-02.24.09-z21.88-chunk1-code1-601eeaba6fceb0b12e8bd2207cbbd0d10cc46bd6/gaussian-t3477.484-3798
                verify(data,'164','02.24.09','601eeaba6fceb0b12e8bd2207cbbd0d10cc46bd6','1',21.88)...
                
                %
                %6	10.2 mins	164-02.26.09-z16.64-chunk1-code1-62deed3b19e0d48279bf0088124922453f1d48f5/gaussian-t5035.364-5650
                %7	5.5 mins	164-02.26.09-z16.605-chunk1-code1-446205caba5bfc04e081ab0bfc5dbe276ceae70c/gaussian-t250.176-583
                %8	6.0 mins	164-02.26.09-z15.84-chunk1-code1-df67d35e42365666c2ac8904516e96e7ac687f01/gaussian-t572.34-935
                verify(data,'164','02.26.09','62deed3b19e0d48279bf0088124922453f1d48f5','1',16.64)...
                
                %
                %9	49.0 mins	164-03.13.09-z17.62-chunk1-code1-1dde0e88c83352d9790baa30af013905e63a48e7/gaussian-t1202.274-4140.2955
                verify(data,'164','03.13.09','1dde0e88c83352d9790baa30af013905e63a48e7','1',17.62)...
                
                %
                %10	32.3 mins	164-03.17.09-z9.255-chunk1-code1-3b43c16b7b96f501204aa3bca54bd522856d2320/gaussian-t964.331-2903.654
                %11	13.6 mins	164-03.17.09-z8.58-chunk1-code1-f2bf60d0a7dd03eb10ec24d6620d82cb05a63d90/gaussian-t1592.508-2409.56
                %12	12.1 mins	164-03.17.09-z8.58-chunk3-code1-f2bf60d0a7dd03eb10ec24d6620d82cb05a63d90/gaussian-t2409.56-3133
                verify(data,'164','03.17.09','3b43c16b7b96f501204aa3bca54bd522856d2320','1',9.255)...
                
                %
                %13	5.7 mins	164-03.19.09-z8.255-chunk1-code1-60085edf1083730b0fd41d344ebfa927c0b73863/gaussian-t488.415-829
                verify(data,'164','03.19.09','60085edf1083730b0fd41d344ebfa927c0b73863','1',8.255)...
                
                % NO STA?
                %14	9.2 mins	164-03.25.09-z19.97-chunk3-code1-532cda6b0d73b8f85e47b43b74e96871897a523e/gaussian-t2487.518-3042
                
                %
                %15	30.3 mins	164-03.25.09-z18.55-chunk1-code1-fd0540a23f6a44ae778fdc547bb870bf9bd1f5e0/gaussian-t335.022-2154.425
                verify(data,'164','03.25.09','fd0540a23f6a44ae778fdc547bb870bf9bd1f5e0','1',18.55)...
                
                %
                %16	9.6 mins	164-03.25.09-z19.2-chunk1-code1-d6ed451b974604f67bca8bb76c3b4cba6d6bdb67/gaussian-t998.45-1576
                %17	24.6 mins	164-03.25.09-z19.2-chunk1-code1-9d10d71ac6e4d1de0f7a8d88ca27b72790f9553d/gaussian-t1670-3144.317 -- getting added extra cuz we don't check times!
                %18	117.5 mins	164-03.25.09-z19.2-chunk1-code1-9d10d71ac6e4d1de0f7a8d88ca27b72790f9553d/gaussian-t5861.42-12912
                %19	14.6 mins	164-03.25.09-z19.2-chunk1-code1-c7b84a4cc5df11db1aedcccf4c12f85dace99275/gaussian-t0-875
                verify(data,'164','03.25.09','9d10d71ac6e4d1de0f7a8d88ca27b72790f9553d','1',19.2)...
                
                % NO STA?
                %20	20.8 mins	164-04.07.09-z7.76-chunk1-code1-891c8c7f8286129461df5aa06b799ead54d28176/gaussian-t233.748-1480
                %21	13.2 mins	164-04.07.09-z7.76-chunk2-code1-891c8c7f8286129461df5aa06b799ead54d28176/gaussian-t1480-2270.726
                
                %
                %22	43.3 mins	164-04.15.09-z47.34-chunk1-code1-acf4f35b54186cd6055697b58718da28e7b2bf80/gaussian-t2042.385-4641
                verify(data,'164','04.15.09','acf4f35b54186cd6055697b58718da28e7b2bf80','1',47.34)...
                
                %
                %23	17.5 mins	164-04.17.09-z47.88-chunk2-code1-89493235e157403e6bad4b39b63b1c6234ea45dd/gaussian-t3891.4-4941
                verify(data,'164','04.17.09','89493235e157403e6bad4b39b63b1c6234ea45dd','2',47.88)...
                
                %
                %24	21.0 mins	188-04.23.09-z38.885-chunk3-code1-4b45921ce9ef4421aa984128a39f2203b8f9a381/gaussian-t3683.4435-4944.054
                verify(data,'188','04.23.09','4b45921ce9ef4421aa984128a39f2203b8f9a381','3',38.885)...
                
                % NO STA?
                %25	7.0 mins	188-04.23.09-z38.26-chunk1-code1-a7e4526229bb5cd78d91e543fc4a0125360ea849/gaussian-t30.292-449.144
                %26	24.5 mins	188-04.23.09-z38.26-chunk1-code1-a7e4526229bb5cd78d91e543fc4a0125360ea849/gaussian-t1269.025-2739.628
                
                % INTERNEURON?
                %27	55.7 mins	188-04.24.09-z52.48-chunk1-code1-9196f9c63cf78cac462dac2cedd55306961b7fd0/gaussian-t5554.8235-8895.053
                verify(data,'188','04.24.09','9196f9c63cf78cac462dac2cedd55306961b7fd0','1',52.48)...
                
                
                %%%gausgrass
                %
                %1	36.7 mins	188-04.29.09-z27.89-chunk1-code1-eb9916e6e433e0599a743952acd19ec218eb83cb/gaussgrass-t2346.139-4550.633
                %2	19.2 mins	188-04.29.09-z27.83-chunk1-code1-c298e72f2ac2edbe8c043c41e72ebc6432394504/gaussgrass-t524.068-1677.573
                verify(data,'188','04.29.09','eb9916e6e433e0599a743952acd19ec218eb83cb','1',27.89)...
                
                
                %
                %3	35.7 mins	188-05.06.09-z28.04-chunk1-code1-e8b33f5945b56d2bb55c8c098a1d72de73206822/gaussgrass-t1524.329-3667.67
                verify(data,'188','05.06.09','e8b33f5945b56d2bb55c8c098a1d72de73206822','1',28.04)...
                
                ]);
            
                case 'hateren' % 8
                    out = any([...
                        %1	68.6 mins	164-03.13.09-z17.62-chunk1-code1-1dde0e88c83352d9790baa30af013905e63a48e7/hateren-t4159.88-8276 -- gaussian 9
                        verify(data,'164','03.13.09','1dde0e88c83352d9790baa30af013905e63a48e7','1',17.62)...
                        
                        %2	8.6 mins	164-03.25.09-z19.97-chunk1-code1-532cda6b0d73b8f85e47b43b74e96871897a523e/hateren-t1120.69-1634 -- guassian 14 (removing cuz no sta)
                        %3	6.1 mins	164-03.25.09-z19.97-chunk2-code1-532cda6b0d73b8f85e47b43b74e96871897a523e/hateren-t1633-1997.585
                        % verify(data,'164','03.25.09','532cda6b0d73b8f85e47b43b74e96871897a523e','1',19.97)...
                        
                        %4	36.0 mins	164-03.25.09-z19.2-chunk1-code1-9d10d71ac6e4d1de0f7a8d88ca27b72790f9553d/hateren-t3693.239-5854.765 -- gaussian 16
                        verify(data,'164','03.25.09','9d10d71ac6e4d1de0f7a8d88ca27b72790f9553d','1',19.2)...
                        
                        %5	24.2 mins	164-04.07.09-z7.76-chunk3-code1-891c8c7f8286129461df5aa06b799ead54d28176/hateren-t3013.366-4465 -- gaussian 20 (removing cuz no sta)
                        % verify(data,'164','04.07.09','891c8c7f8286129461df5aa06b799ead54d28176','3',7.76)...
                        
                        %6	33.5 mins	164-04.15.09-z47.34-chunk1-code1-acf4f35b54186cd6055697b58718da28e7b2bf80/hateren-t0.001-2012.453 -- gaussian 22
                        verify(data,'164','04.15.09','acf4f35b54186cd6055697b58718da28e7b2bf80','1',47.34)...
                        
                        %7	34.9 mins	164-04.17.09-z47.88-chunk1-code1-89493235e157403e6bad4b39b63b1c6234ea45dd/hateren-t1321.791-3415 -- gaussian 23
                        %8	7.7 mins	164-04.17.09-z47.88-chunk2-code1-89493235e157403e6bad4b39b63b1c6234ea45dd/hateren-t3412-3876.868
                        verify(data,'164','04.17.09','89493235e157403e6bad4b39b63b1c6234ea45dd','1',47.88)...
                        
                        %9	53.4 mins	188-04.23.09-z38.885-chunk3-code1-4b45921ce9ef4421aa984128a39f2203b8f9a381/hateren-t5951.891-9156 -- gaussian 24
                        verify(data,'188','04.23.09','4b45921ce9ef4421aa984128a39f2203b8f9a381','3',38.885)...
                        
                        %10	12.1 mins	188-04.23.09-z38.66-chunk4-code1-4b45921ce9ef4421aa984128a39f2203b8f9a381/hateren-t9156-9882 -- gaussian 25 (removing cuz no sta)
                        %11	35.9 mins	188-04.23.09-z38.26-chunk5-code3-4b45921ce9ef4421aa984128a39f2203b8f9a381/hateren-t10123-12278
                        %12	91.7 mins	188-04.23.09-z38.26-chunk1-code1-a7e4526229bb5cd78d91e543fc4a0125360ea849/hateren-t2757.8325-8260
                        % verify(data,'188','04.23.09','a7e4526229bb5cd78d91e543fc4a0125360ea849','1',38.26)...
                        
                        %13	7.8 mins	188-04.24.09-z52.48-chunk1-code1-9196f9c63cf78cac462dac2cedd55306961b7fd0/hateren-t8902.91-9370 -- gaussian 27
                        verify(data,'188','04.24.09','9196f9c63cf78cac462dac2cedd55306961b7fd0','1',52.48)...
                        
                        %14	24.8 mins	188-04.29.09-z27.89-chunk1-code1-eb9916e6e433e0599a743952acd19ec218eb83cb/hateren-t4559.181-6050 -- gaussgrass 1
                        %15	110.1 mins	188-04.29.09-z27.83-chunk1-code1-c298e72f2ac2edbe8c043c41e72ebc6432394504/hateren-t4854.675-11463
                        verify(data,'188','04.29.09','c298e72f2ac2edbe8c043c41e72ebc6432394504','1',27.83)...
                        
                        %16	66.4 mins	188-05.06.09-z28.04-chunk1-code1-e8b33f5945b56d2bb55c8c098a1d72de73206822/hateren-t3680.88-7664 -- gaussgrass 3
                        verify(data,'188','05.06.09','e8b33f5945b56d2bb55c8c098a1d72de73206822','1',28.04)...
                        
                        ]);

                otherwise
                    out=false;

            end
            
        case 'cosyne2010'
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
            %out = strcmp(data.ratID,'164') && strcmp(stimType,'gaussian') && strcmp(data.date,'03.17.09') && ismember(data.hash,{'f2bf60d0a7dd03eb10ec24d6620d82cb05a63d90'}) && data.z==8.58 && ismember(data.chunkNum,{'1'});
        otherwise
            error('unrecognized')
    end
end
end

function out=verify(data,id,date,hash,chunk,z)
out=strcmp(data.ratID,id) && strcmp(data.date,date) && strcmp(data.hash,hash) && data.z==z && strcmp(data.chunkNum,chunk);
end