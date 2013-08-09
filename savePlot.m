function [] = savePlot(saveName,outputDir,formats,figHandle,resolution)    
    if ~exist(outputDir,'dir')
        mkdir(outputDir);
        warning('Output folder did not exist. Thus it was created!');
    end  
    for i = 1:length(formats)
       switch  formats(i)               
           case 1               
               print(figHandle, '-djpeg', strcat('-r',resolution),char(strcat(outputDir,filesep, saveName,'.jpg'))); 
           case 2                                     
               print(figHandle, '-dpng', strcat('-r',resolution),char(strcat(outputDir,filesep, saveName,'.png')));            
           case 3
               saveas(figHandle,[char(outputDir) char(filesep) char(saveName) char('.fig')],'fig');               
           case 4               
               print(figHandle, '-dtiff', strcat('-r',resolution),char(strcat(outputDir,filesep, saveName,'.tiff')));            
           case 5               
               print(figHandle, '-dbmp', strcat('-r',resolution),char(strcat(outputDir,filesep, saveName,'.bmp')));            
           case 6                              
               print(figHandle, '-dpdf', strcat('-r',resolution),char(strcat(outputDir,filesep, saveName,'.pdf')));                           
           case 7                                             
               export_fig(strcat(outputDir,filesep, saveName,'.eps'),'-eps','-transparent',figHandle);
           case 8               
               print(figHandle, '-depsc', strcat('-r',resolution),char(strcat(outputDir,filesep, saveName,'Col.eps')));                      
           case 9               
               print(figHandle, '-deps2', strcat('-r',resolution),char(strcat(outputDir,filesep, saveName,'L2.eps')));            
           case 10                        
               print(figHandle, '-depsc2', strcat('-r',resolution),char(strcat(outputDir,filesep, saveName,'L2Col.eps')));            
       end
    end        
end