# Compilador
Creación de un compilador para la materia de Compiladores de la Facultad de Ingeniería 2023-2

Autores: 
    -Carlos Castelan Ramos
    -Carlos Eduaro Rivas Solis

------------------------------------------------Para más información revisar documentación-----------------------------------------------------

Objetivo1.
    Elaborar un analizador léxico en lex/flex que reconozca los componentes léxicos pertenecientes a las clases abajo descritas.

Propuesta de solución 1.
    Implementación de un programa escrito en lex y c que identifique y clasifique mediante expresiones regulares los datos que se reciban mediante un archivo externo de entrada con extensión .txt. Para que así después de su clasificación se inserten en tablas dinámicas según se piden en los requerimientos. 
    La explicación detallada de esta propuesta se encuentra en el diseño e implementación.

-----------------------------------------------------------------------------------------------------------------------------------------------

Objetivo2.
    Construir, en un mismo programa, los analizadores Léxico y Sintáctico Descendente Recursivo que revisen programas escritos en el lenguaje definido por la gramática del Anexo A de este documento.

Descripción del problema2.
    Dada la construcción previa de la primera parte del compilador con el analizador léxico, logramos diferenciar y clasificar el lenguaje natural con el uso de las clases definidas en la primera parte de la documentación aplicando expresiones regulares expresadas en tokens con el uso del paquete flex/lex de Bison en un programa escrito en lenguaje C. 
    Es entonces, que hechas las debidas correcciones del analizador léxico (revisar apartado de correcciones), comenzamos con el planteamiento del problema para la implementación del analizador sintáctico. 
    Debemos tener un analizador sintáctico, que trabaje a partir de los tokens generados con el analizador léxico, para que así mediante el uso de funciones creadas con la aplicación del método de Análisis Sintáctico Descendente Recursivo (a partir de ahora lo llamaremos ASDR) identifique los átomos que aparecen en los tokens y los almacene en una cadena. Además por defecto al aplicar el método de ASDR es necesario calcular los conjuntos de selección de las gramáticas declaradas en el Anexo A donde estos deben de cumplir con las características de una Gramática LL(1). Así finalmente con los conjuntos de selección y las funciones creadas en C del ASDR tendremos la aplicación de una correcta sintaxis del orden de los tokens generados del análisis léxico, donde tendremos que mostrar los casos en los que las funciones pueden fallar.

Propuesta de solución.
    Implementación de un programa escrito en C y lex hecho a partir del programa del análisis léxico, consiguiendo así el análisis léxico-sintáctico.
    Para esto, es necesario aplicar el método del Analizador Sintáctico Descendente Recursivo, el cual deriva del uso y aplicación de la metodología de las Gramáticas LL(1), donde se deben obtener los conjuntos de selección de las producciones mostradas en el Anexo A.
    Aplicando el ASDR obtendremos las funciones de cada No Terminal (NT) para su construcción recursiva mediante el uso de llamadas y así obtener la correcta aplicación de sintaxis acompañada de sus excepciones para la identificación de errores.
    Enseguida es necesario crear las sentencias adecuadas que identifiquen los átomos de cada clase definidas en el analizador léxico, para su posterior almacenamiento en alguna lista y así finalmente obtener la cadena de átomos del analizador sintáctico.
    La explicación detallada de esta propuesta se encuentra en el diseño e implementación.