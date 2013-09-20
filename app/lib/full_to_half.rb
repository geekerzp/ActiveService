# vi: set fileencoding=utf-8 :
require 'full_to_half'
class String  

        @@hchars = ' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~'  
        @@fchars = '　！＂＃＄％＆＇（）＊＋，－．／０１２３４５６７８９：；＜＝＞？＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ［＼］＾＿｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ｛｜｝～'  
        @@hhash = {' '=>'　','!'=>'！','"'=>'＂','#'=>'＃','$'=>'＄','%'=>'％','&'=>'＆','\''=>'＇','('=>'（',')'=>'）','*'=>'＊',
                   '+'=>'＋',','=>'，','-'=>'－','.'=>'．','/'=>'／','0'=>'０','1'=>'１','2'=>'２','3'=>'３','4'=>'４','5'=>'５',
                   '6'=>'６','7'=>'７','8'=>'８','9'=>'９',':'=>'：',';'=>'；','<'=>'＜','='=>'＝','>'=>'＞','?'=>'？','@'=>'＠',
                   'A'=>'Ａ','B'=>'Ｂ','C'=>'Ｃ','D'=>'Ｄ','E'=>'Ｅ','F'=>'Ｆ','G'=>'Ｇ','H'=>'Ｈ','I'=>'Ｉ','J'=>'Ｊ','K'=>'Ｋ',
                   'L'=>'Ｌ','M'=>'Ｍ','N'=>'Ｎ','O'=>'Ｏ','P'=>'Ｐ','Q'=>'Ｑ','R'=>'Ｒ','S'=>'Ｓ','T'=>'Ｔ','U'=>'Ｕ','V'=>'Ｖ',
                   'W'=>'Ｗ','X'=>'Ｘ','Y'=>'Ｙ','Z'=>'Ｚ','['=>'［','\\'=>'＼',']'=>'］','^'=>'＾','_'=>'＿','`'=>'｀','a'=>'ａ',
                   'b'=>'ｂ','c'=>'ｃ','d'=>'ｄ','e'=>'ｅ','f'=>'ｆ','g'=>'ｇ','h'=>'ｈ','i'=>'ｉ','j'=>'ｊ','k'=>'ｋ','l'=>'ｌ',
                   'm'=>'ｍ','n'=>'ｎ','o'=>'ｏ','p'=>'ｐ','q'=>'ｑ','r'=>'ｒ','s'=>'ｓ','t'=>'ｔ','u'=>'ｕ','v'=>'ｖ','w'=>'ｗ',
                   'x'=>'ｘ','y'=>'ｙ','z'=>'ｚ','{'=>'｛','|'=>'｜','}'=>'｝','~'=>'～'}
        @@fhash = {'　'=>' ','！'=>'!','＂'=>'"','＃'=>'#','＄'=>'$','％'=>'%','＆'=>'&','＇'=>'\'','（'=>'(','）'=>')',
                   '＊'=>'*','＋'=>'+','，'=>',','－'=>'-','．'=>'.','／'=>'/','０'=>'0','１'=>'1','２'=>'2','３'=>'3',
                   '４'=>'4','５'=>'5','６'=>'6','７'=>'7','８'=>'8','９'=>'9','：'=>':','；'=>';','＜'=>'<','＝'=>'=',
                   '＞'=>'>','？'=>'?','＠'=>'@','Ａ'=>'A','Ｂ'=>'B','Ｃ'=>'C','Ｄ'=>'D','Ｅ'=>'E','Ｆ'=>'F','Ｇ'=>'G',
                   'Ｈ'=>'H','Ｉ'=>'I','Ｊ'=>'J','Ｋ'=>'K','Ｌ'=>'L','Ｍ'=>'M','Ｎ'=>'N','Ｏ'=>'O','Ｐ'=>'P','Ｑ'=>'Q',
                   'Ｒ'=>'R','Ｓ'=>'S','Ｔ'=>'T','Ｕ'=>'U','Ｖ'=>'V','Ｗ'=>'W','Ｘ'=>'X','Ｙ'=>'Y','Ｚ'=>'Z','［'=>'[',
                   '＼'=>'\\','］'=>']','＾'=>'^','＿'=>'_','｀'=>'`','ａ'=>'a','ｂ'=>'b','ｃ'=>'c','ｄ'=>'d','ｅ'=>'e',
                   'ｆ'=>'f','ｇ'=>'g','ｈ'=>'h','ｉ'=>'i','ｊ'=>'j','ｋ'=>'k','ｌ'=>'l','ｍ'=>'m','ｎ'=>'n','ｏ'=>'o',
                   'ｐ'=>'p','ｑ'=>'q','ｒ'=>'r','ｓ'=>'s','ｔ'=>'t','ｕ'=>'u','ｖ'=>'v','ｗ'=>'w','ｘ'=>'x','ｙ'=>'y',
                   'ｚ'=>'z','｛'=>'{','｜'=>'|','｝'=>'}','～'=>'~'}

        def to_full_width  
            str = self  
            str.gsub!(/([#{@@hchars}])/){|c|@@hhash[c]}  
            str  
        end  
          
        def to_half_width  
            str = self  
            str.gsub!(/([#{@@fchars}])/){|c|@@fhash[c]}  
            str  
        end  
    end  
