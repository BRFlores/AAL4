#!/usr/bin/perl

#Procesamiento de Lenguajes Naturales
#Profesor: Dr. Josafá Pontes
#Nombres y apellidos: Ejemplo
#Direccion de traducción: English-French

use Encode;
use utf8;
use HTML::Entities;#Convert html encoding into utf8 plain text and vice versa
use warnings;
use strict;
binmode STDOUT, ":utf8";


if (! defined $ARGV[0]) {die "Formato de uso: \nperl regex_remplazo.pl input_directory\nEjemplo de uso:\nperl regex_remplazo.pl html_input\n";}
main($ARGV[0]);#Calling main procedure


sub main {
   my ($directoryName) = @_;

   #Opening directory and storing file names into an array
   my @fileList = &readFiles($directoryName);
   foreach my $fileName (@fileList) {
      my $htmlFileContent = openFile($fileName);
	  #Para convertir en UTF-8
	  $htmlFileContent = decode_entities($htmlFileContent);

$htmlFileContent=~ s/(<font[^)]*>\(<\/font>\s*<font[^>]*>\b(?:prét|pp)\b<\/font>\s*<font[^>]*>(?:(?!<\/font>).)*<\/font>\s*[^\)]*\)<\/font>)/"<font 
style=\"font-weight:bold;font-style:italic;color:#357EC7;\">".removeFontTags($1)."<\/font>"/eg;

=pod
	  #1. Shifting isolated punctuation mark into previous font tag.
      $htmlFileContent =~ s/<\/font>\s*<font[^>]*>\s*([;,\.\?\!])\s*(<\/font>)/$1$2/g;

	  #2. Concatenar las frases que tengan el mismo formato de font
	  $htmlFileContent =~ s/(<font style="color:#FFCC99;">(?:(?:(?!<\/font>).)*))<\/font>\s*<font style="color:#FFCC99;">((?:(?!<\/font>).)*<\/font>\s*)/$1 $2/g;

	  #3. Concatenar la información adicional de las entradas y dejar toda la cadena en un formato único de tag de font
	  # Se necesita la 's' porque no se sabe, a priori, cuantos tag de fonts hay que remover
	  $htmlFileContent =~ s/(<font style="font-weight:bold;">\/(?:(?:(?!\/<\/font>).)*)\/)(<\/font>)/"<font style=\"color:#FFCC99;\">".removeFontTags($1).$2/gse;

	  #4. Se cambia de color a las entradas de todos los diccionarios
	  $htmlFileContent =~ s/(<body>\s*<p>\s*)(<font style="font-weight:bold;color:#0000FF;">)((?:(?!<\/font>).)*<\/font>\s*)(<font[^>]*>(?:(?!<\/font>).)*<\/font>\s*)?(<\/p>)/"$1<font style=\"font-weight:bold;color:#0066FF;\">$3".imprime($4).$5/eg;

	  #5. Cambiar de colores a la numeración de las utilizaciones
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#FF0080;">)([0-9]+<\/font>\s*)/<p><font style="font-weight:bold;color:#FFA500;">$2/g;

	  #6. Cambiar de colores a los números romanos y que servirán de ayuda para la segmentación del archivo HTML en sus diferentes secciones
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#FF0080;">\s*)([IVX]+\s*<\/font>\s*)/<p><font style="font-weight:bold;color:#990099;">$2/g;

      #áúéíóúñ
	  #7. Concatenar la información de las etiquetas morfológicas y dejar toda la cadena en un único tag de font
	  $htmlFileContent =~ s/<font style="font-style:italic;color:#4E9258;">((?:(?:(?!<\/font>).)*))<\/font>\s*<font style="font-style:italic;">((?:(?:(?!<\/font>).)*))<\/font>\s*/<font style="font-style:italic;color:#4E9258;">$1$2<\/font>\n   /g;

      #8. Cambiar de formato a todas las etiquetas morfológicas y dejarlas con un formato estándar
	  $htmlFileContent =~ s/(<font style="font-style:italic;">)([^\[\]\;]+<\/font>\s*)/<font style="font-style:italic;color:#4E9258;">$2/g;

	  #9. Concatenar la información de la inflexión de las morfologias y dejar toda la cadena en un formato único de tag de font
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#990099;">\s*[IVX]+\s*<\/font>\s*(?:<font[^>]*>(?:(?!<\/font>).)*<\/font>)?\s*<font style="font-style:italic;color:#4E9258;">(?:(?!<\/font>).)*<\/font>\s*)(<font style="font-weight:bold;color:#808080;">\((?:(?!\)<\/font>).)*\)<\/font>)/$1."<font style=\"font-weight:bold;font-style:italic;color:#357EC7;\">".removeFontTags($2)."<\/font>"/egs;

	  #10. Para trasladar la información adicional de las morfologias, que no sean las inflexiones, como información de utilización
      #$htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#990099;">\s*[IVX]+\s*<\/font>\s*(?:<font[^>]*>(?:(?!<\/font>).)*<\/font>)?\s*(?:<font[^>]*>(?:(?!<\/font>).)*<\/font>)?\s*<font style="font-style:italic;color:#4E9258;">(?:(?!<\/font>).)*<\/font>(?:\s*<font style="font-weight:bold;font-style:italic;color:#357EC7;">(?:(?!<\/font>).)*<\/font>)?(?!\n<\/p>))((?:(?!<\/p>|<font style="font-weight:bold;font-style:italic;color:#357EC7;">).)*<\/p>)/$1\n<\/p>\n\n<p><font style="font-weight:bold;color:#FFA500;">1<\/font>$2/gs;
	  while ($htmlFileContent =~ /(<p><font style="font-weight:bold;color:#990099;">\s*[IVX]+\s*<\/font>\s*(?:<font[^>]*>(?:(?!<\/font>).)*<\/font>)?\s*(?:<font[^>]*>(?:(?!<\/font>).)*<\/font>)?\s*<font style="font-style:italic;color:#4E9258;">(?:(?!<\/font>).)*<\/font>(?:\s*<font style="font-weight:bold;font-style:italic;color:#357EC7;">(?:(?!<\/font>).)*<\/font>)?(?!\n<\/p>))((?:(?!<\/p>|<font style="font-weight:bold;font-style:italic;color:#357EC7;">).)*<\/p>)(\s*(?:(?!<p><font style="font-weight:bold;color:#FFA500;">[0-9]+<\/font>)[^\n])+)/gs) {
         $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#990099;">\s*[IVX]+\s*<\/font>\s*(?:<font[^>]*>(?:(?!<\/font>).)*<\/font>)?\s*(?:<font[^>]*>(?:(?!<\/font>).)*<\/font>)?\s*<font style="font-style:italic;color:#4E9258;">(?:(?!<\/font>).)*<\/font>(?:\s*<font style="font-weight:bold;font-style:italic;color:#357EC7;">(?:(?!<\/font>).)*<\/font>)?(?!\n<\/p>))((?:(?!<\/p>|<font style="font-weight:bold;font-style:italic;color:#357EC7;">).)*<\/p>)(\s*(?:(?!<p><font style="font-weight:bold;color:#FFA500;">[0-9]+<\/font>)[^\n])+)/$1\n<\/p>\n\n<p><font style="font-weight:bold;color:#FFA500;">1<\/font>$2$3/gs;
      }

	  #11. Concatenar las frases que tengan el mismo formato de font
	  while ($htmlFileContent =~ /(<font[^>]*>)((?:(?!<\/font>).)*)(<\/font>\s*)\1/g) {
         $htmlFileContent =~ s/(<font[^>]*>)((?:(?!<\/font>).)*)(<\/font>\s*)\1/$1$2 /g;
      }
	  
      #12. Se coloca la etiqueta especial #l% %l# a las localizaciones geográficas
	  $htmlFileContent =~ s/(<font[^>]*>)((?:(?!<\/font>).)+[^'’\#\%])?(\b(?:GB|US)\b)((?:(?!<\/font>).)*)(<\/font>)/"$1".imprime($2)."#l%$3%l#$4$5"/eg;

      #13. Concatenar las frases bilingues del mismo idioma en un solo tag de font que se encuentran en la parte de las utilizaciones
      $htmlFileContent =~ s/(<font style="font-weight:bold;color:#808080;">)((?:(?!<\/font>).)*)<\/font>\s*<font style="font-weight:bold;font-style:italic;">(\([^\)]+\))<\/font>\s*\1((?:(?!<\/font>).)*<\/font>)/$1$2#l%$3%l# $4/g;

      #14. Corrigiendo referencias de "also" dispersa entre tags de font.
      $htmlFileContent =~ s/<font[^>]*>\s*\(<\/font>\s*<font[^>]*>\s*also<\/font>\s*<font[^>]*>((?:(?!<\/font>).)*)\)\s*<\/font>/<font style="font-weight:bold;font-style:italic;color:#800000;">(also #r%$1%r#)<\/font>/g;

      #15. Formateando traducciones con el estandar apropiado.
	  $htmlFileContent =~ s/<font style="font-weight:bold;">\s*\(((?:(?!<\/font>).)*)\s*<\/font>\s*<font style="font-weight:bold;color:#808080;">((?:(?!<\/font>).)*)\)([\.,:;\?\!\s]*)<\/font>/<font style="font-weight:bold;color:#C47451;">(#1%$1%1# #2%$2%2#)$3<\/font>/g;

      #16. Formateando traducciones con el estandar apropiado.
	  $htmlFileContent =~ s/<font style="font-weight:bold;">\s*\(((?:(?!<\/font>).)*)\s*<\/font>\s*<font style="font-weight:bold;color:#808080;">((?:(?!<\/font>).)*);<\/font>\s*<font style="font-weight:bold;">\s*((?:(?!<\/font>).)*)\s*<\/font>\s*<font style="font-weight:bold;color:#808080;">((?:(?!<\/font>).)*)\)([\.,:;\?\!\s]*)<\/font>/<font style="font-weight:bold;color:#C47451;">\(#1%$1%1# #2%$2%2#; #1%$3%1# #2%$4%2#)$5<\/font>/g;

	  #17. Se retiran los 2 puntos (:) luego de las palabras compuestas para estandarizar la 3ra sección del diccionario
      $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#0000B2;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-weight:bold;color:#0000FF;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-weight:bold;color:#808080;">(?:(?!<\/font>).)*<\/font>\s*)?(<\/p>)/$1\n$3/g;

      #18. Desplazando el punto coma ubicado inicialmente al inicio de un tag de font hacia el tag de font anterior.
      $htmlFileContent =~ s/(<\/font>\s*<font[^>]*>)\s*;\s*/;$1/g;

	  #19. Agregar etiqueta morfológica a los diccionarios que carecen de ella
	  $htmlFileContent =~ s/(<body>\s*<p><font style="font-weight:bold;color:#0066FF;">(?:(?:(?!<\/font>).)*)<\/font>\s*<font style="color:#FFCC99;">(?:(?:(?!<\/font>).)*)<\/font>\s*<\/p>\s*)(<p><font style="font-weight:bold;color:#FFA500;">[0-9]+<\/font>)/$1<p><font style="font-weight:bold;color:#990099;">I<\/font>\n   <font style="font-style:italic;color:#4E9258;">sin etiqueta morfológica<\/font>\n<\/p>\n$2/g;

      #20. Se retira los 2 puntos (:) que se encuentran al final de las palabras compuestas
      $htmlFileContent =~ s/(<p><font[^>]*>\s*(?:(?:(?!<font style="font-weight:bold;color:#808080;">:<\/font>).)*)<\/font>)\s*(<font style="font-weight:bold;color:#808080;">:<\/font>\s*<\/p>)/$1\n<\/p>/gs;

      #21. Se retira los 2 puntos (:) que se encuentran al final de las palabras compuestas - Parte 2
      $htmlFileContent =~ s/(<p><font[^>]*>\s*(?:(?:(?!<font style="font-weight:bold;color:#808080;">:<\/font>).)*)<\/font>)\s*(<font style="font-weight:bold;color:#808080;">:<\/font>\s*)(<font[^>]*>(?:(?:(?!<\/p>).)*)<\/p>)/$1\n<\/p>\n<p>$3/gs;

	  #22. Estandarizar la sección de Palabras Compuestas
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#0000B2;">(?:(?:(?!<\/font>).)*)<\/font>\s*<font style="font-weight:bold;color:#0000FF;">(?:(?:(?!<\/font>).)*)<\/font>)\s*(<font[^>]*>((?:(?:(?!<\/p>).)*))<\/p>\s*)/$1\n<\/p>\n<p>$2/gs;

      #23. Trasladar a un nuevo tag de font cuando se encuentre un punto y coma (;) en la mitad del texto de dicho tag de font
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;">(?:(?!<\/font>).)*<\/font>\s*<font style="color:#FF00FF;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-weight:bold;color:#808080;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-style:italic;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-weight:bold;color:#808080;"(?:(?!<\/font>).)*<\/font>\s*<font style="font-style:italic;">\s*(?:(?!<\/font>).)*);((?:(?!<\/font>).)*<\/font>\s*<font style="font-weight:bold;color:#808080;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-style:italic;">(?:(?!<\/font>).)*<\/font>\s*<\/p>)/$1\;<\/font>\n   <font style="font-style:italic;">$2/g;

      #24. Trasladar a un nuevo tag de font cuando se encuentre un punto y coma (;) en la mitad del texto de dicho tag de font
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-style:italic;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-weight:bold;color:#808080;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-style:italic;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-weight:bold;color:#808080;"(?:(?!<\/font>).)*<\/font>\s*<font style="font-style:italic;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-weight:bold;color:#808080;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-weight:bold;">(?:(?!<\/font>).)*<\/font>\s*<font style="color:#FF00FF;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-weight:bold;color:#808080;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-style:italic;">(?:(?!<\/font>).)*<\/font>\s*<font style="color:#A23BEC">(?:(?!<\/font>).)*<\/font>\s*<font style="color:#FF00FF;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-style:italic;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-weight:bold;color:#808080;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-style:italic;">(?:(?!<\/font>).)*);((?:(?!<\/font>).)*<\/font>\s*<font style="font-weight:bold;color:#808080;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-style:italic;">(?:(?!<\/font>).)*<\/font>\s*<\/p>)/$1\;<\/font>\n   <font style="font-style:italic;">$2/g;

      #25. Trasladar a un nuevo tag de font cuando se encuentre un punto y coma (;) en la mitad del texto de dicho tag de font
      $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#FFA500;">(?:(?!<\/font>).)*<\/font>\s*<font style="color:#FF00FF;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-style:italic;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-weight:bold;color:#808080;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-style:italic;">(?:(?!<\/font>).)*);((?:(?!<\/font>).)*<\/font>\s*<font style="font-weight:bold;color:#808080;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-style:italic;">(?:(?!<\/font>).)*<\/font>\s*<font style="color:#A23BEC">(?:(?!<\/font>).)*<\/font>\s*<font style="font-weight:bold;color:#808080;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-style:italic;">(?:(?!<\/font>).)*<\/font>\s*<\/p>)/$1\;<\/font>\n   <font style="font-style:italic;">$2/g;

	  #26. Agregando número romano a los archivos que no lo tienen
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#0000FF;">(?:(?:(?!<\/font>).)*)<\/font>\s*<font style="font-weight:bold;color:#808080;">(?:(?:(?!<\/font>).)*)<\/font>\s*<font style="color:#FFCC99;">(?:(?:(?!<\/font>).)*)<\/font>)\s*(<font style="font-style:italic;color:#4E9258;">(?:(?:(?!<\/font>).)*)<\/font>\s*)(<\/p>)/$1\n<\/p>\n\n<p><font style="font-weight:bold;color:#990099;">I<\/font>\n   $2$3\n/;

	  #27. Para estandarizar la información de las morfologías, ingresando el número romano, la etiqueta morfológica y la numeración a aquellos archivos que no lo tienen
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;font-style:italic;color:#800000;">(?:(?:(?!<\/font>).)*)<\/font>\s*<\/p>)\s*(<p>)(<font style="font-style:italic;">(?:(?:(?!<\/font>).)*)<\/font>\s*(<font style="font-weight:bold;">(?:(?:(?!<\/font>).)*)<\/font>)?\s*<font style="font-weight:bold;color:#808080;">(?:(?:(?!<\/font>).)*)<\/font>\s*)(<\/p>)/$1\n\n<p><font style="font-weight:bold;color:#990099;">I<\/font>\n   <font style="font-style:italic;color:#4E9258;">sin etiqueta morfológica<\/font>\n<\/p>\n\n<p><font style="font-weight:bold;color:#FFA500;">1<\/font>\n   $3<\/p>/g;

	  #28. Para estandarizar la información de las morfologías, ingresando el número romano, la etiqueta morfológica y la numeración a aquellos archivos que no lo tienen - Parte 2
	  $htmlFileContent =~ s/<p><font style="font-weight:bold;color:#008000;">((?:(?:(?!<\/font>).)*))<\/font>\s*<font style="font-weight:bold;">((?:(?:(?!<\/font>).)*))<\/font>\s*(<font style="font-style:italic;color:#4E9258;">(?:(?:(?!<\/font>).)*)<\/font>)\s*(<font style="font-weight:bold;color:#808080;">(?:(?:(?!<\/font>).)*)<\/font>\s*<\/p>)/<p><font style="font-weight:bold;color:#0066FF;">$1<\/font>\n<\/p>\n\n<p><font style="font-weight:bold;color:#990099;">I<\/font>\n   <font style="color:#DC381F;">$2<\/font>\n   $3\n<\/p>\n\n<p><font style="font-weight:bold;color:#FFA500;">1<\/font>\n   $4/g;

      #29. Para estandarizar la información adicional de las utilizaciones
	  $htmlFileContent =~ s/<font style="font-weight:bold;color:#808080;">\(<\/font>\s*<font style="font-weight:bold;font-style:italic;">((?:(?:(?!<\/font>).)*))<\/font>\s*<font style="font-weight:bold;color:#808080;">\=<\/font>\s*<font style="font-weight:bold;">((?:(?:(?!<\/font>).)*))<\/font>\s*/<font style="font-weight:bold;font-style:italic;">\($1 = $2<\/font>\n   /g;

	  #30. Para estandarizar la información de las morfologías, ingresando el número romano, y concatenando la etiqueta morfológica de aquellos archivos que no lo tienen - Parte 3
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#0066FF;">(?:(?:(?!<\/font>).)*)<\/font>)\s*(<font style="font-style:italic;color:#4E9258;">(?:(?:(?!<\/font>).)*)<\/font>\s*)(<\/p>)/$1\n<\/p>\n\n<p><font style="font-weight:bold;color:#990099;">I<\/font>\n   $2$3/;

	  #31. Para estandarizar la información de las morfologías, ingresando el número romano, y concatenando la etiqueta morfológica de aquellos archivos que no lo tienen - Parte 4
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;font-style:italic;color:#800000;">(?:(?:(?!<\/font>).)*)<\/font>\s*<\/p>)\s*(<p>)(<font style="font-style:italic;color:#4E9258;">(?:(?:(?!<\/font>).)*)<\/font>)\s*(<font style="font-weight:bold;color:#808080;">(?:(?:(?!<\/font>).)*)<\/font>\s*<\/p>)/$1\n\n<p><font style="font-weight:bold;color:#990099;">I<\/font>\n   $3\n<\/p>\n\n<p><font style="font-weight:bold;color:#FFA500;">1<\/font>\n   $4/;

	  #32. Para estandarizar la información de las morfologías, ingresando el número romano, y concatenando la etiqueta morfológica de aquellos archivos que no lo tienen - Parte 5
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#0000FF;">(?:(?:(?!<\/font>).)*)<\/font>)\s*(<font style="font-style:italic;color:#4E9258;">(?:(?:(?!<\/font>).)*)<\/font>)\s*(<font[^>]*>\s*(?:(?:(?!<\/p>).)*)<\/p>)/$1\n<\/p>\n\n<p><font style="font-weight:bold;color:#990099;">I<\/font>\n   $2\n<\/p>\n\n<p><font style="font-weight:bold;color:#FFA500;">1<\/font>\n   $3/gs;

	  #33. Para estandarizar la información de las morfologías, ingresando el número romano, y concatenando la etiqueta morfológica de aquellos archivos que no lo tienen - Parte 6
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;font-style:italic;color:#800000;">(?:(?:(?!<\/font>).)*)<\/font>\s*<\/p>)\s*(<p>)(<font style="font-style:italic;color:#4E9258;">(?:(?:(?!<\/font>).)*)<\/font>)\s*(<font[^>]*>\s*(?:(?:(?!<\/p>).)*)<\/p>)/$1\n\n<p><font style="font-weight:bold;color:#990099;">I<\/font>\n   $3\n<\/p>\n\n<p><font style="font-weight:bold;color:#FFA500;">1<\/font>\n   $4/gs;

	  #34. Se cambia de color a la numeración de los archivos que no hayan sido afectados con los primeras expresiones regulares
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#0000FF;">)((?:(?:(?!<\/font>).)*)<\/font>)/<p><font style="font-weight:bold;color:#0066FF;">$2/;

	  #35. Para estandarizar la información de las morfologías, ingresando el número romano, y concatenando la etiqueta morfológica de aquellos archivos que no lo tienen - Parte 7
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#0066FF;">(?:(?:(?!<\/font>).)*)<\/font>\s*<font style="color:#FFCC99;">(?:(?:(?!<\/font>).)*)<\/font>)\s*(<font style="font-style:italic;color:#4E9258;">(?:(?:(?!<\/font>).)*)<\/font>)\s*(<font[^>]*>\s*(?:(?:(?!<\/p>).)*)<\/p>)/$1\n<\/p>\n\n<p><font style="font-weight:bold;color:#990099;">I<\/font>\n   $2\n<\/p>\n\n<p><font style="font-weight:bold;color:#FFA500;">1<\/font>\n   $3/gs;

	  #36. Para estandarizar la información de las morfologías, ingresando el número romano, y concatenando la etiqueta morfológica de aquellos archivos que no lo tienen - Parte 8
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#0066FF;">(?:(?:(?!<\/font>).)*)<\/font>\s*<font style="color:#FFCC99;">(?:(?:(?!<\/font>).)*)<\/font>)\s*(<font style="font-style:italic;color:#4E9258;">(?:(?:(?!<\/font>).)*)<\/font>)\s*(<\/p>)/$1\n<\/p>\n\n<p><font style="font-weight:bold;color:#990099;">I<\/font>\n   $2\n<\/p>\n\n/;

	  #37. Para concatenar los tags de font que están en párrafos distintos y que tienen las mismas características. Para los archivos del lote 2
	  $htmlFileContent =~ s/(<font style="font-weight:bold;color:#FF0000;">((?:(?!<\/font>).)*)<\/font>\s*<\/p>)\s*(<p><font style="font-weight:bold;color:#FF0000;">((?:(?!<\/font>).)*)<\/font>)/<font style="font-weight:bold;color:#FF0000;">$2 $4<\/font>\n   /g;

	  #38. Para segmentar en diferentes tags de font la información de los romanos y las numeraciones que se encuentran en un mismo tag de font. Para los archivos del lote 2
	  $htmlFileContent =~ s/(<font style="font-weight:bold;color:#FF0000;">[IVX]+)\,((?:(?:(?!<\/font>).)*)<\/font>)/$1<\/font>\n   <font style="font-weight:bold;color:#FF0000;">$2\n   /g;

	  #39. Para tener el color de las palabras etiquetadas de manera estándar
	  $htmlFileContent =~ s/(<font>)(#l%(?:(?!\s).)*)((?:(?!<\/font>).)*)(<\/font>)/<font style="color:#A23BEC">$2<\/font>\n   $1$3$4/g;
	  
	  #40. Para concatenar la información del archivo 046312.htm que tiene una tag de font que sale del estándar - <i><font color="#0000b3" face="BoldItalic">
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#0000B2;">)((?:(?!<\/font>).)*)(<\/font>)\s*#b%<i><font color="#0000b3" face="BoldItalic">((?:(?!<\/font>).)*)<\/font><\/i>%b#\s*(<\/p>)/$1$2 #i%$4%i# $3\n$5/g;

	  #41. Para estandarizar la información del archivo 033362.htm que tiene una tag de font que sale del estándar - <i style='mso-bidi-font-style:normal'>
	  $htmlFileContent =~ s/<font style="font-weight:bold;">((?:(?!<i style='mso-bidi-font-style:normal'>).)*)<i style='mso-bidi-font-style:normal'>((?:(?!<\/i>).)*)<\/i>(\s*\=\s*)<i style='mso-bidi-font-style: normal'>((?:(?!<\/i>).)*)<\/i>(\s*)<i style='mso-bidi-font-style:normal'>((?:(?!<\/i>).)*)<\/i>(\s*\=\s*)<i style='mso-bidi-font-style:normal'>((?:(?!<\/i>).)*)<\/i>(;\s*)<i style='mso-bidi-font-style:normal'>((?:(?!<\/i>).)*)<\/i>(\s*\=\s*)<i style='mso-bidi-font-style:normal'>((?:(?!<\/i>).)*)<\/i>((?:(?!<i style='mso-bidi-font-style:normal'>).)*)<i style='mso-bidi-font-style:normal'>((?:(?!<\/i>).)*)<\/i>((?:(?!<\/font>).)*)<\/font>/<font style="font-weight:bold;font-style:italic;">$1$2$3$4<\/font>\n<font style="font-weight:bold;font-style:italic;">$6$7$8$9<\/font>\n<font style="font-weight:bold;font-style:italic;">$10$11$12\.<\/font>\n<font style="font-weight:bold;">$13<\/font>\n<font style="font-weight:bold;font-style:italic;">$14$15<\/font>/;
	  ##$htmlFileContent =~ s/<i style='mso-bidi-font-style:normal'>((?:(?!<\/i>).)*)<\/i>/<font style="font-weight:bold;font-style:italic;">$1<\/font>/g;
	  ###while ($htmlFileContent =~ /<i style='mso-bidi-font-style:normal'>((?:(?!<\/i>).)*)<\/i>\1/g) {
         ###$htmlFileContent =~ s/<i style='mso-bidi-font-style:normal'>((?:(?!<\/i>).)*)<\/i>\1/<font style="font-weight:bold;font-style:italic;">$1<\/font>/g;
      ###}

	  #42. Para estandarizar la información de las morfologías, ingresando el número romano, concatenando la etiqueta morfológica y la numeración de la utilización de aquellos archivos que no lo tienen - Parte 3
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#0066FF;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-weight:bold;">(†)((?:(?!<\/font>).)*)<\/font>)\s*(<font style="color:#FFCC99;">((?:(?!<\/font>).)*)<\/font>)\s*(<font style="font-weight:bold;">\/)((?:(?:(?!<\/font>).)*)<\/font>)\s*(<font style="font-style:italic;color:#4E9258;">(?:(?!<\/font>).)*<\/font>)\s*(<font[^>]*>(?:(?!<\/p>).)*<\/p>)/$1\n   <font style="color:#FFCC99;">$4$6\/<\/font>\n<\/p>\n\n<p><font style="font-weight:bold;color:#990099;">I<\/font>\n   <font style="font-weight:bold;">$3<\/font>\n   $9\n<\/p>\n\n<p><font style="font-weight:bold;color:#FFA500;">1<\/font>\n   $10/gs;

	  #43. Para estandarizar la información de las morfologías, ingresando el número romano, concatenando la etiqueta morfológica y la numeración de la utilización de aquellos archivos que no lo tienen - Parte 3
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#008000;">)\s*((?:(?!<\/font>).)*)<\/font>\s*(<font style="font-style:italic;color:#4E9258;">(?:(?!<\/font>).)*<\/font>)\s*(<font[^>]*>(?:(?!<\/p>).)*<\/p>)/<p><font style="font-weight:bold;color:#0066FF;">$2<\/font>\n<\/p>\n\n<p><font style="font-weight:bold;color:#990099;">I<\/font>\n   $3\n<\/p>\n\n<p><font style="font-weight:bold;color:#FFA500;">1<\/font>\n   $4/gs;

	  #44. Para estandarizar la información de las morfologías, ingresando el número romano, concatenando la etiqueta morfológica y la numeración de la utilización de aquellos archivos que no lo tienen - Parte 3
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#0066FF;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-weight:bold;">((?:(?!\/<\/font>).)*)\/<\/font>)\s*(<font style="color:#FFCC99;">)((?:(?!<\/font>).)*)(<\/font>)\s*(<font style="font-weight:bold;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-style:italic;color:#4E9258;">(?:(?!<\/font>).)*<\/font>)\s*(<font[^>]*>(?:(?!<\/p>).)*<\/p>)/$1\n   $4\/$5\/$6\n<\/p>\n\n<p><font style="font-weight:bold;color:#990099;">I<\/font>\n   $8\n<\/p>\n\n<p><font style="font-weight:bold;color:#FFA500;">1<\/font>\n   <font style="font-weight:bold;">$3<\/font>\n   $9/gs;

	  #45. Para estandarizar la información de las morfologías, ingresando el número romano, concatenando la etiqueta morfológica y la numeración de la utilización de aquellos archivos que no lo tienen - Parte 3 - archivo 000050.htm
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#0066FF;">(?:(?!<\/font>).)*<\/font>\s*<font style="color:#FFCC99;">(?:(?!<\/font>).)*<\/font>)\s*<font style="font-weight:bold;color:#808080;">((?:(?!<\/font>).)*)<\/font>\s*<font style="font-weight:bold;font-style:italic;">((?:(?!<\/font>).)*)<\/font>\s*<font style="font-weight:bold;color:#808080;">((?:(?!<\/font>).)*)<\/font>\s*<\/p>\s*(<p><font style="font-weight:bold;color:#990099;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-style:italic;color:#4E9258;">(?:(?!<\/font>).)*<\/font>)\s*(<\/p>)/$1\n$6\n\n$5\n   <font style="font-weight:bold;font-style:italic;color:#357EC7;">$2$3 $4<\/font>\n$6/;

	  #46. Para estandarizar la información de las morfologías, ingresando el número romano, concatenando la etiqueta morfológica y la numeración de la utilización de aquellos archivos que no lo tienen - Parte 3 - archivo 000094.htm
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#0066FF;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-weight:bold;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-style:italic;color:#4E9258;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="color:#A23BEC">(?:(?!<\/font>).)*<\/font>)\s*(<font>(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-weight:bold;color:#808080;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="color:#A23BEC">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-weight:bold;color:#808080;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-weight:bold;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-weight:bold;color:#808080;">(?:(?!<\/font>).)*<\/font>)\s*(<\/p>)/$1\n<\/p>\n\n<p><font style="font-weight:bold;color:#990099;">I<\/font>\n   $3\n<\/p>\n\n<p><font style="font-weight:bold;color:#FFA500;">1<\/font>\n   $2\n   $4\n   $5\n   $6\n   $7\n   $8\n   $9\n   $10\n$11/;

	  #47. Para estandarizar la información de las morfologías, ingresando el número romano, concatenando la etiqueta morfológica y la numeración de la utilización de aquellos archivos que no lo tienen - Parte 3 - archivo 000122.htm
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#0066FF;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-weight:bold;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="color:#FFCC99;">)((?:(?!<\/font>).)*)\s*(<\/font>)\s*(<font style="font-weight:bold;">\/)\s*((?:(?!<\/font>).)*)\s*(<\/font>\s*<\/p>)\s*(<p><font style="font-weight:bold;color:#990099;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-style:italic;color:#4E9258;">(?:(?!<\/font>).)*<\/font>\s*<\/p>)\s*(<p><font style="font-weight:bold;color:#FFA500;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-weight:bold;color:#808080;">(?:(?!<\/font>).)*<\/font>\s*<\/p>)/$1\n   $3\/$4\/$5\n<\/p>\n\n$9\n\n$10\n   <font style="color:#A23BEC">$7<\/font>\n   $11/;

	  #48. Para estandarizar la información de las morfologías, ingresando el número romano, concatenando la etiqueta morfológica y la numeración de la utilización de aquellos archivos que no lo tienen - Parte 3 - archivo 000134.htm
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#990099;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-style:italic;color:#4E9258;">(?:(?!\[).)*)((?:(?!<\/font>).)*)(<\/font>\s*<\/p>)\s*(<p><font style="font-weight:bold;color:#FFA500;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-weight:bold;color:#808080;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-style:italic;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-weight:bold;color:#808080;">(?:(?!<\/font>).)*<\/font>)\s*(<\/p>)/$1\n   $2$4\n\n$5\n   <font style="font-style:italic;">$3<\/font>\n   $6\n   $7\n   $8\n$9/;

	  #49. Para estandarizar la información de las morfologías, ingresando el número romano, concatenando la etiqueta morfológica y la numeración de la utilización de aquellos archivos que no lo tienen - Parte 3 - archivo 000179.htm
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#990099;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-style:italic;color:#4E9258;">(?:(?!\[).)*)\s*((?:(?!<\/font>).)*<\/font>)\s*(<font style="font-weight:bold;font-style:italic;color:#357EC7;">(?:(?!<\/font>).)*<\/font>\s*<\/p>)\s*(<p><font style="font-weight:bold;color:#FFA500;">(?:(?!<\/font>).)*<\/font>)\s*(<font[^>]*>(?:(?!<\/p>).)*<\/p>)/$1\n   $2<\/font>\n   $4\n\n$5\n   <font style="font-style:italic;">$3\n   $6/gs;

	  #50. Para estandarizar la información de las morfologías, ingresando el número romano, concatenando la etiqueta morfológica y la numeración de la utilización de aquellos archivos que no lo tienen - Parte 3 - archivo 000179.htm
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#0066FF;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-weight:bold;color:#808080;">(?:(?!<\/font>).)*<\/font>\s*<font style="color:#FFCC99;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-style:italic;color:#4E9258;">(?:(?!<\/font>).)*<\/font>)\s*(<font[^>]*>(?:(?!<\/p>).)*<\/p>)/$1\n<\/p>\n\n<p><font style="font-weight:bold;color:#990099;">I<\/font>\n   $2\n<\/p>\n\n<p><font style="font-weight:bold;color:#FFA500;">1<\/font>\n   $3/gs;

	  #51. Para estandarizar la información de las morfologías, ingresando el número romano, concatenando la etiqueta morfológica y la numeración de la utilización de aquellos archivos que no lo tienen - Parte 3 - archivo 000239.htm
	  $htmlFileContent =~ s/(<p><font style="font-weight:bold;color:#0066FF;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-weight:bold;">\/<\/font>)\s*(<font style="color:#FFCC99;">)((?:(?!<\/font>).)*)(<\/font>)\s*(<font style="font-weight:bold;">\/)\s*(((?:(?!<\/font>).)*)<\/font>)\s*(<font[^>]*>(?:(?!<\/p>).)*<\/p>)/$1\n   $3\/$4\/$5\n<\/p>\n\n<p><font style="font-weight:bold;color:#990099;">I<\/font>\n   <font style="font-style:italic;color:#4E9258;">sin etiqueta morfológica<\/font>\n<\/p>\n\n<p><font style="font-weight:bold;color:#FFA500;">1<\/font>\n   <font style="color:#A23BEC">$7\n   $9/gs;

	  #52. Para estandarizar la información de las morfologías, ingresando el número romano, concatenando la etiqueta morfológica y la numeración de la utilización de aquellos archivos que no lo tienen - Parte 3 - archivo 000250.htm
	  $htmlFileContent =~ s/<p><font style="font-weight:bold;color:#008000;">((?:(?!<\/font>).)*)<\/font>\s*(<font style="color:#A23BEC">(?:(?!<\/font>).)*<\/font>\s*<font style="font-weight:bold;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-style:italic;color:#4E9258;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-weight:bold;color:#808080;">(?:(?!<\/font>).)*<\/font>\s*<\/p>)/<p><font style="font-weight:bold;color:#0066FF;">$1<\/font>\n<\/p>\n\n<p><font style="font-weight:bold;color:#990099;">I<\/font>\n   $3\n<\/p>\n\n<p><font style="font-weight:bold;color:#FFA500;">1<\/font>\n   $2\n   $4/gs;

	  #53. Para estandarizar la información de las morfologías, ingresando el número romano, concatenando la etiqueta morfológica y la numeración de la utilización de aquellos archivos que no lo tienen - Parte 3 - archivo 000268.htm
	  $htmlFileContent =~ s/<p><font style="font-weight:bold;color:#008000;">((?:(?!<\/font>).)*)<\/font>\s*(<font style="color:#FFCC99;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-style:italic;color:#4E9258;">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-weight:bold;color:#808080;">(?:(?!<\/font>).)*<\/font>\s*<\/p>)/<p><font style="font-weight:bold;color:#0066FF;">$1<\/font>\n   $2\n<\/p>\n\n<p><font style="font-weight:bold;color:#990099;">I<\/font>\n   $3\n<\/p>\n\n<p><font style="font-weight:bold;color:#FFA500;">1<\/font>\n   $4/;

	  #54. Para estandarizar la información de las morfologías, ingresando el número romano, concatenando la etiqueta morfológica y la numeración de la utilización de aquellos archivos que no lo tienen - Parte 3 - archivo 000252.htm
	  $htmlFileContent =~ s/<p><font style="font-weight:bold;color:#008000;">((?:(?!<\/font>).)*)<\/font>\s*(<font style="color:#A23BEC">(?:(?!<\/font>).)*<\/font>)\s*(<font style="font-weight:bold;">(?:(?!<\/font>).)*<\/font>)\s*<\/p>\s*(<p><font style="font-weight:bold;font-style:italic;color:#800000;">(?:(?!<\/font>).)*<\/font>\s*<\/p>)\s*(<p><font style="font-weight:bold;color:#990099;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-style:italic;color:#4E9258;">(?:(?!<\/font>).)*<\/font>\s*<\/p>)\s*(<p><font style="font-weight:bold;color:#FFA500;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-weight:bold;color:#808080;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-weight:bold;font-style:italic;">(?:(?!<\/font>).)*<\/font>\s*<font style="font-weight:bold;color:#808080;">(?:(?!<\/font>).)*<\/font>\s*<\/p>)/<p><font style="font-weight:bold;color:#0066FF;">$1<\/font>\n<\/p>\n\n$4\n\n$5\n\n$6\n\n<p><font style="font-weight:bold;color:#FFA500;">2<\/font>\n   $2\n   $3\n<\/p>/;
=cut

      #Storing the output
      &storeNewFile($fileName, $htmlFileContent);

   }#\for
}


sub trim {
   my ($str) = @_;
   $str =~ s/^ *| *$//g;
   return $str;
}


#When $str is filled, the function returns the full tag
#empty otherwise.
sub printOrNot {
   my ($openTag, $str ,$closeTag) = @_;

   if ($str !~ /^$/) {
      $str = $openTag.$str.$closeTag;
   }

   return $str;
}


#Returns the string if defined, empty otherwise.
sub imprime {
   my ($str) = @_;

   if (!defined $str) {
      $str = "";
   }

   return $str;
}


#Receives text between pairs of font tags
#Produces one string without html tags.
sub removeFontTags {
   my ($str) = @_;
   $str =~ s/\s*<font[^>]*>|<\/font>\s*/ /g;
   $str =~ s/ {2,}/ /g;
   return trim($str);
}


#Receives text between pairs of empty paragraphs
#Produces one string without html tags.
sub removeParagraph {
   my ($str) = @_;
   $str =~ s/\s*<p>|<\/p>\s*/ /g;
   $str =~ s/ {2,}/ /g;
   return trim($str);
}

#Removing leading and trailing white spaces
sub removeBlankSpaces {
   my ($str) = @_;
   
   if (length($str) >= 0) {
      $str =~ s/\s//g;
   }
   
   return trim($str);
}


sub simplifyRepeatedFonts {
   my ($htmlFileContent) = @_;

   my $fontStyle01 = "<font style=\"font-weight:bold;font-style:italic;color:#800000;\">";
   my $fontStyle02 = "<font style=\"font-weight:bold;font-style:italic;color:#808080;\">";
   my $fontStyle03 = "<font style=\"font-weight:bold;font-style:italic;\">";
   my $fontStyle04 = "<font style=\"font-weight:bold;color:#FF0080;\">";
   my $fontStyle05 = "<font style=\"font-weight:bold;color:#0000B2;\">";
   my $fontStyle06 = "<font style=\"font-weight:bold;color:#0000FF;\">";
   my $fontStyle07 = "<font style=\"font-weight:bold;color:#808080;\">";
   my $fontStyle08 = "<font style=\"font-weight:bold;color:#FF0000;\">";
   my $fontStyle09 = "<font style=\"font-style:italic;\">";
   my $fontStyle10 = "<font style=\"font-weight:bold;\">";
   my $fontStyle11 = "<font style=\"color:#FFCC99;\">";
   my $fontStyle12 = "<font style=\"color:#FF0080;\">";
   my $fontStyle13 = "<font style=\"color:#FF00FF;\">";
   my $fontStyle14 = "<font>";
  
   $htmlFileContent =~ s/($fontStyle01)((?:(?!<\/font>).)*)<\/font>\s*$fontStyle01((?:(?!<\/font>).)*<\/font>)/$1$2 $3/g;
   $htmlFileContent =~ s/($fontStyle02)((?:(?!<\/font>).)*)<\/font>\s*$fontStyle02((?:(?!<\/font>).)*<\/font>)/$1$2 $3/g;
   $htmlFileContent =~ s/($fontStyle03)((?:(?!<\/font>).)*)<\/font>\s*$fontStyle03((?:(?!<\/font>).)*<\/font>)/$1$2 $3/g;
   $htmlFileContent =~ s/($fontStyle04)((?:(?!<\/font>).)*)<\/font>\s*$fontStyle04((?:(?!<\/font>).)*<\/font>)/$1$2 $3/g;
   $htmlFileContent =~ s/($fontStyle05)((?:(?!<\/font>).)*)<\/font>\s*$fontStyle05((?:(?!<\/font>).)*<\/font>)/$1$2 $3/g;
   $htmlFileContent =~ s/($fontStyle06)((?:(?!<\/font>).)*)<\/font>\s*$fontStyle06((?:(?!<\/font>).)*<\/font>)/$1$2 $3/g;
   $htmlFileContent =~ s/($fontStyle07)((?:(?!<\/font>).)*)<\/font>\s*$fontStyle07((?:(?!<\/font>).)*<\/font>)/$1$2 $3/g;
   $htmlFileContent =~ s/($fontStyle08)((?:(?!<\/font>).)*)<\/font>\s*$fontStyle08((?:(?!<\/font>).)*<\/font>)/$1$2 $3/g;
   $htmlFileContent =~ s/($fontStyle09)((?:(?!<\/font>).)*)<\/font>\s*$fontStyle09((?:(?!<\/font>).)*<\/font>)/$1$2 $3/g;
   $htmlFileContent =~ s/($fontStyle10)((?:(?!<\/font>).)*)<\/font>\s*$fontStyle10((?:(?!<\/font>).)*<\/font>)/$1$2 $3/g;
   $htmlFileContent =~ s/($fontStyle11)((?:(?!<\/font>).)*)<\/font>\s*$fontStyle11((?:(?!<\/font>).)*<\/font>)/$1$2 $3/g;
   $htmlFileContent =~ s/($fontStyle12)((?:(?!<\/font>).)*)<\/font>\s*$fontStyle12((?:(?!<\/font>).)*<\/font>)/$1$2 $3/g;
   $htmlFileContent =~ s/($fontStyle13)((?:(?!<\/font>).)*)<\/font>\s*$fontStyle13((?:(?!<\/font>).)*<\/font>)/$1$2 $3/g;
   $htmlFileContent =~ s/($fontStyle14)((?:(?!<\/font>).)*)<\/font>\s*$fontStyle14((?:(?!<\/font>).)*<\/font>)/$1$2 $3/g;	

   return $htmlFileContent;	
}


sub storeNewFile {
   my ($fileName, $fileContent) = @_;
   my $directoryName = "limpio";

   if ( -d "$directoryName") {
      print "Directory found \"$directoryName/$fileName\"\n";
   } else {
        print "Directory \"$directoryName\" was not found, but it has just been created.\n";
        mkdir("$directoryName");
   }

   #Removing directory name from the inicial input.
   $fileName =  substr($fileName, index ($fileName, "/")+1, (length ($fileName) - index ($fileName, "/")+1));
   &writeFile("$directoryName\\$fileName", $fileContent);
}


#Creates a new file.
#Deletes all content of old file, if existed.
sub writeFile {
   my ($fileName, $content) = @_;#
   #writing content into a file.
   #open FILE, ">$fileName";
   open (FILE, ">:utf8",$fileName) or die "Can't read file \"$fileName\" [$!]\n";
   print FILE $content;
   close (FILE);
}


sub readFiles {
   my ($folder) = @_;
   my @files = <$folder/*>;
   return @files;
}


sub openFile {
   my ($fileName) = @_;
   local $/;#read full file instead of only one line.
   open (FILE, "<:utf8",$fileName) or die "Can't read file \"$fileName\" [$!]\n";
   my $fileContent = <FILE>;
   close (FILE);

   return $fileContent;
} 