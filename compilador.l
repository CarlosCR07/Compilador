%{
    /*
    Authors:    Castelan Ramos Carlos
                Rivas Solis Carlos Eduardo
                
    Date:       28/0ct/2022 - 01/nov/2022
    Objetivo: Elaborar un analizador léxico en lex/flex que 
            reconozca los componentes léxicos pertenecientes 
            a las clases abajo descritas.

    Date: 03/Dic/2022 - 05/Dic/2022
    Objetivo 2: Construir, en un mismo programa, los analizadores Léxico y Sintáctico Descendente Recursivo que
    revisen programas escritos en el lenguaje definido por la gramática del Anexo A de este
    documento.
    */

    /*Librerias utilizadas.*/
    #include<stdio.h>
    #include<string.h>
    #include<stdlib.h>

    /*ARCHIVO DE ENTRADA A COMPILAR.*/
    FILE *file;
    
    /*ARCHIVOS QUE ALMACENAN TABLAS.*/
    FILE *ArchGeneral;
    FILE *ArchPalabrasReservadas;
    FILE *ArchIdentificadores;
    //FILE *ArchEnterasOctales; //CORRECCIONES
    FILE *ArchConsReales;
    FILE *ArchCadenas;
    FILE *ArchEspeciales;
    FILE *ArchAritmeticos;
    FILE *ArchRelacionales;
    FILE *ArchNoReconocidos;
    /******* File para la cadena de átomos *******************/
    FILE *ArchCadenaAtomos;

    

    /***************************************************************************************************/
    /*********************** DECLARACIÓN DE FUNCIONES DEL SINTÁCTICO ***********************************/
    /***************************************************************************************************/

    //Variable que identifica atomos
    char c;
    char* cadena;
    int indice=0;
    //Funciones generalizadas
    void abrirArchivos();
    void imprimirAchivos();
    void cerrarArchivos();
    //Convertidor de token a atomo
    char* atomos(char* id);
    //Lista de atomos
    // int addAtomo(char id[1]);
    //Convierte lista de átomos a cadena de átomos.
    // char* getCadena(struct list lista);
    //Funciones Genericas
    void getAtomo();
    void acepta();
    void error();
    //Funciones ASD
    void Program();
    void otraFunc();
    void Func();
    void Param();
    void otroParam();
    void Cuerpo();
    void Decl();
    void D();
    void Tipo();
    void K();
    void Q();
    void N();
    void C();
    void A();
    void AP();
    void E();
    void EP();
    void T();
    void TP();
    void F();
    void R();
    void RP();
    void V();
    void VP();
    void VPP();
    void VPPP();
    void P();
    void listaP();
    void W();
    void I();
    void IP();
    void J();
    void Y();
    void X();
    void Z();
    void H();
    void CP();
    void OP();
    void U();
    void Devuelve();
    void valor();
    void Llama();
    void arg();
    void otroArg();

    /****************************************************************************************/
    /****************** FUNCIONES DEL ANALIZADOR LÉXICO *************************************/
    /****************************************************************************************/

    /*TABLA ESTATICA DE PALABRAS RESERVADAS.*/
	char reservada[17][12] = {"alternative","big","evaluate","instead","large","loop","make","number","other","real","repeat","select","small","step","stop","symbol","throw"};
	int tamanoReservada = 17;

    /*TABLA ESTATICA DE SÍMBOLOS ESPECIALES.*/
	char especial[9][3] = {"[","]","(",")","{","}",",",":",";"};
	int tamanoEspecial = 9;

    /*TABLA ESTATICA DE OPERADORES ARITMÉTICOS.*/
	char aritmetico[7][3] = {"+","-","*","/","%%","\\","^"};
	int tamanoAritmetico = 7;

    /*TABLA ESTATICA DE OPERADORES RELACIONALES.*/
	char relacional[6][3] = {"<",">","<=",">=","==","!="};
	int tamanoRelacional = 6;

    /*ESTRUCTURAS Y FUNCIONES PARA CREAR TABLAS DE SIMBOLOS Y LITERALES.*/

    //Estructura nodo lista ligada.
    typedef struct node{
        struct node* sig; //apunta al siguiente nodo.
        char dato[50]; //campo almacena dato.
    }Node;

    //Declara estructura de las listas.
    struct list{
        Node* init; //nodo apunta al nodo inicio.
        Node* fin;	//nodo apunta nodo final de la lista.
        int size;
    }listaEnterasOctales,listaReales,listaCadenas,listaNoReconocidos, listaAtomos; //Listas que almacenan las tablas.

    //Estructura nodo lista ligada para identificador.
    typedef struct nodeIdentificador{
        struct nodeIdentificador* sig; //apunta al siguiente nodo.
        int tipo;
        char dato[]; //campo almacena dato.
    }NodeIdentificador;

    //Declara estructura de las listas.
    struct listIdentificador{
        NodeIdentificador* init; //nodo apunta al nodo inicio.
        NodeIdentificador* fin;	//nodo apunta nodo final de la lista.
        int size;
    }listaIdentificadores; //Listas que almacenan las tablas.

    //Inicializa o añade elementos a la tabla de Enteros y Octales
    int addList(char atomo[], struct list *lista, int clase){
        if(lista->init == NULL){
            lista->init = (Node*)malloc(sizeof(Node));
            lista->init ->sig = NULL;
            lista->fin = lista->init;
            lista->size = 0;
            strcpy(lista->init->dato, atomo);
            fprintf(ArchGeneral, "(%d,%d) \n", clase, lista->size);
            return 0;
        }
        Node* aux = (Node*)malloc(sizeof(Node));
        lista->fin->sig = aux;
        lista->fin = aux;
        strcpy(lista->fin->dato, atomo);
        lista->fin->sig = NULL;
        lista->size++;
        fprintf(ArchGeneral, "(%d,%d) \n", clase, lista->size);
        return 1;
    }

    //Inicializa o añade elementos a la tabla de Enteros y Octales
    int addListCadena(char atomo[100], struct list *lista, int clase){
        if(lista->init == NULL){
            lista->init = (Node*)malloc(sizeof(Node));
            lista->init ->sig = NULL;
            lista->fin = lista->init;
            lista->size = 0;
            strcpy(lista->init->dato, atomo);
            fprintf(ArchGeneral, "(%d,%d) \n", clase, lista->size);
            return 0;
        }
        Node* aux = (Node*)malloc(sizeof(Node));
        lista->fin->sig = aux;
        lista->fin = aux;
        strcpy(lista->fin->dato, atomo);
        lista->fin->sig = NULL;
        lista->size++;
        fprintf(ArchGeneral, "(%d,%d) \n", clase, lista->size);
        return 1;
    }

    //Inicializa o añade elementos a la tabla de Identificadores
    int addListIdentificador(char atomo[100]){
        if(listaIdentificadores.init == NULL){
            listaIdentificadores.init = (NodeIdentificador*)malloc(sizeof(NodeIdentificador));
            listaIdentificadores.init ->sig = NULL;
            listaIdentificadores.fin = listaIdentificadores.init;
            listaIdentificadores.size = 0;
            strcpy(listaIdentificadores.init->dato, atomo);
            listaIdentificadores.init->tipo = -1;
            fprintf(ArchGeneral, "(1,%d) \n", listaIdentificadores.size);
            // printf("%s es un Identificador\n", yytext);
            //addAtomo("i"); //Añade el atomo a la lista atomos
            return 0;
        }

        //Recorre lista para buscar identificador
        int posicion=0;
        NodeIdentificador* aux= listaIdentificadores.init;
        while(aux != NULL){
            if(!strcmp(aux->dato, atomo)){ //Verifica si esta en el nodo
                // printf("%s es un Identificador duplicado(no se anexara a la tabla)\n", yytext);
                return posicion; //Regresa la posicion en la lista
            }
            else{
                aux = aux->sig; //Pasa al siguiente nodo
                posicion ++;
            }
        }

        //Si no está en la lista, inserta al final
        NodeIdentificador* auxi = (NodeIdentificador*)malloc(sizeof(NodeIdentificador));
        listaIdentificadores.fin->sig = auxi;
        listaIdentificadores.fin = auxi;
        strcpy(listaIdentificadores.fin->dato, atomo);
        listaIdentificadores.fin->tipo = -1;
        listaIdentificadores.fin->sig = NULL;
        listaIdentificadores.size++;
        fprintf(ArchGeneral, "(1,%d) \n", listaIdentificadores.size);
        // printf("%s es un Identificador\n", yytext);
        //addAtomo("i"); //Añade el atomo a la lista atomos
        return 1;
    }

    //IMPRESION DE TABLAS Y GUARDADO EN DOCUMENTO
    //Escribe la tabla actual de Constantes Reales en un archivo nuevo o editado.
    void printTabla(struct list tabla, FILE *archivo, char nombre[]){
        Node* aux = tabla.init;
        int pos = 0;
        fprintf(archivo,"Tabla de %s\nÍndice    Valor\n", nombre);
        if(tabla.size < 0){ //Es menor que 0 porque las listas al iniciar con un solo valor, se les considera con "0"
            fprintf(archivo,"La lista no tiene elementos.\n");
        }else{
            while(aux != NULL){
            fprintf(archivo,"%i\t-->\t%s\n",pos++,aux->dato);
            aux = aux->sig;
            }
        }
    }

    //Escribe la tabla de Palabras Reservadas en un archivo nuevo o editado.
    void printTablaEstatica(FILE *archivo, char nombre[], int tamano, char tabla[][3]){
        fprintf(archivo,"Tabla de %s\nÍndice    Valor\n", nombre);
        for(int i=0; i<tamano; i++){
            fprintf(archivo,"%i\t-->\t%s\n",i,tabla[i]);
        }
    }

    //Escribe la tabla de Símbolos Especiales en un archivo nuevo o editado.
    void printTablaReservadas(){
        fprintf(ArchPalabrasReservadas,"Tabla de Palabras reservadas\nÍndice    Valor\n");
        for(int i=0; i<tamanoReservada; i++){
            fprintf(ArchPalabrasReservadas,"%i\t-->\t%s\n",i,reservada[i]);
        }
    }

    //Escribe la tabla actual de Identificadores en un archivo nuevo o editado.
    void printTablaIdentificadores(struct listIdentificador tabla){
        NodeIdentificador* aux = tabla.init;
        int pos = 0;
        fprintf(ArchIdentificadores,"Tabla de Identificadores\nÍndice    Valor    Tipo\n");
        if(tabla.size < 0){ //Es menor que 0 porque las listas al iniciar con un solo valor, se les considera con "0"
            fprintf(ArchIdentificadores,"La lista no tiene elementos.\n");
        }else{
            while(aux != NULL){
            fprintf(ArchIdentificadores,"%i\t-->\t%s\t%i\n",pos++,aux->dato,aux->tipo);
            aux = aux->sig;
            }
        }
    }

    //Añadir atomos encontrados a una lista
    int addAtomo(char atomo[1]){
    	if(listaAtomos.init == NULL){
    		listaAtomos.init = (Node*)malloc(sizeof(Node));
    		listaAtomos.init ->sig = NULL;
    		listaAtomos.fin = listaAtomos.init;
    		listaAtomos.size = 0;
    		strcpy(listaAtomos.init->dato, atomo);
    		return 0;
    	}
    	Node* aux = (Node*)malloc(sizeof(Node));
    	listaAtomos.fin->sig = aux;
    	listaAtomos.fin = aux;
    	strcpy(listaAtomos.fin->dato, atomo);
    	listaAtomos.fin->sig = NULL;
    	listaAtomos.size++;
    	return 1;
    }

    //Convertir la lista de átomos en una cadena de átomos.
    char* getCadena(struct list lista){
    	char* cadena=  (char*)malloc(sizeof(char)*lista.size+1);
    	Node* aux = lista.init; //nodo auxiliar igual al nodo inicial
    	int i = 0;
    	while(aux!=NULL){
    		cadena[i++] = aux->dato[0];//copia el atomo de la lista a la cadena
    		aux = aux->sig; //nodo aux es igual al siguiente
    	}
    	cadena[i] = '0';
    	return cadena;
    }

/*Expresiones regulares, sujetas a cambios en las especificaciones.*/
%}

palabrasReservadas alternative|big|evaluate|instead|large|loop|make|number|other|real|repeat|select|small|step|stop|symbol|throw
ident      [$][A-Za-z]+
consInt    0|[1-9]+[0-9]*
consOct    [oO][0-7]+
consReal   [0-9]*\.[0-9]+
consCad    \"[^"]{2,40}\"
caracter   \'[^']{1,1}\'
simbEsp    [\[\](){},:;]
opArith    [\^+\-*/%\\]
opRelac    <|>|<=|>=|==|!=
opAsig     [=]
espacio    [ ]
tabulador  [\t]
saltoLinea [\n]
noReconocido '.'

%%

{palabrasReservadas} {/*printf("%s es una Palabra Rervada", yytext);*/
    {//itera la tabla de p reservadas y busca cual palabra reconocio
        for(int i=0; i<tamanoReservada; ++i){
            if(!strcmp(reservada[i], yytext)){
                fprintf(ArchGeneral, "(0,%d) \n", i);
            }			
        }
        addAtomo(atomos(yytext));//Convierte a atomo y lo añade en su lista
    }
}
{ident} {addListIdentificador(yytext);addAtomo("i");} //Añadir atomo se hace dentro de la funcion de lista de identificadores
{consInt}  {/*printf("%s es un Constante entera\n", yytext);*/
    {//Agrega el token de asignación al archivo general.
        fprintf(ArchGeneral,"(2,%s)\n",yytext);
        addAtomo("n");//Añade atomo en listaAtomos
    }
}
{consOct}  {/*printf("%s es un Constante octal\n", yytext);*/
    {//Agrega el token de asignación al archivo general.
        fprintf(ArchGeneral,"(2,%s)\n",yytext);
        addAtomo("n");//Añade atomo en listaAtomos
    }
}
{consReal} {/*printf("%s es un Constante real\n", yytext);*/ addList(yytext, &listaReales, 3);addAtomo("r");}
{consCad} {/*printf("%s es un Consantes cadenas\n", yytext);*/ addListCadena(yytext, &listaCadenas, 4);addAtomo("s");}
{caracter} {/*printf("%s es un Caracter\n", yytext);*/ addList(yytext, &listaCadenas, 4);addAtomo("s");}
{simbEsp} {/*printf("%s es un Simbolo especial\n", yytext);*/
    {
        {//itera la tabla de símbolos especiales y busca cual palabra reconocio.
            for(int i=0; i<tamanoEspecial; ++i){
                if(!strcmp(especial[i], yytext)){
                    fprintf(ArchGeneral, "(5,%i) \n", i);
                }			
            }
            addAtomo(yytext);//Añade atomo en listaAtomos
        }
    }
}
{opArith} {/*printf("%s es un Operador Aritmético\n", yytext);*/
    {
        {//itera la tabla de operadores aritméticos y busca cual palabra reconocio.
            for(int i=0; i<tamanoAritmetico; ++i){
                if(!strcmp(aritmetico[i], yytext)){
                    fprintf(ArchGeneral, "(6,%i) \n", i);
                }			
            }
            addAtomo(yytext);//Añade atomo en listaAtomos
        }
    }
}
{opRelac} {/*printf("%s es un Operador Relacional\n",yytext);*/
    {//itera la tabla de p relacionales y busca cual palabra reconocio.
        for(int i=0; i<tamanoRelacional; ++i){
            if(!strcmp(relacional[i], yytext)){
                fprintf(ArchGeneral, "(7,%i) \n", i);
            }			
        }
        addAtomo(atomos(yytext)); //Convierte a atomo y lo inserta en su lista
    }
}
{opAsig} {/*printf("%s es un Operador Asignacion\n", yytext);*/
    {//Agrega el token de asignación al archivo general.
        fprintf(ArchGeneral,"(8,=)\n");
        addAtomo("=");//Añade atomo en listaAtomos
    }
}
{espacio} {/*printf("%s es un Espacio\n", yytext);*/}
{tabulador} {/*printf("%s es un Tabulador\n", yytext);*/}
{saltoLinea} {/*printf("%s Hay un Salto de Línea\n", yytext);*/}
{noReconocido} {/*printf("%s es un dato No Reconocido\n", yytext);*/fprintf(ArchNoReconocidos,"%s\n",yytext);}
. {/*printf("%s es un dato No reconocido\n", yytext);*/fprintf(ArchNoReconocidos,"%s\n",yytext);}
%%
/*
. {printf("%s es un dato No reconocido\n", yytext);
    fprintf(ArchNoReconocidos,"%s\n",yytext);
}
*/

/*Función main de nuestro compilador*/
int main(int argc, char *argv[]){
    printf("Probando la compilación . . . \n\n");
    //Busca abrir el archivo fuente.
    if (argc>1){
        file=fopen(argv[1], "r");
        if (file==NULL){
            fprintf(stderr, "error al abrir el fichero %s\n", argv[1]);
            exit (1);
        }
        yyin=file;
        }
    //Con el archivo fuente abiesrto exitosamente, se procede a hacer todo el proceso léxico.
    abrirArchivos();
    //Preparación del archivo de errores/datos no reconocidos.
    fprintf(ArchNoReconocidos,"Datos no reconocidos\n");
    printf("Iniciando analizado léxico . . .\n");
    //Ejecución del analizador léxico.
    yylex();
    printf("Análisis léxico terminado\n\n");
    //Obtenemos la cadena de átomos para procesar.
    cadena =getCadena(listaAtomos);
    printf("Iniciando analizador sintáctico . . .\n");
    //Buscar el primer átomo.
    getAtomo();
    Program();
    printf("Análisis sintáctico terminado\n");
    if(c=='0'){
        acepta();
    }else{
        error();
    }
    //Imprimimos y cerramos los archivos.
    imprimirAchivos();
    cerrarArchivos();
    return 0;
}

/****************************************************************************************/
/****************** FUNCIONES DEL ANALIZADOR SINTÁCTICO **********************************/
/****************************************************************************************/

//Convertir Token a Atomo
char* atomos(char* id){
    //Palabras reservadas
	if(!strcmp("alternative",id))
			return "a";
	if(!strcmp("big",id))
			return "b";
    if(!strcmp("evaluate",id))
			return "f";
    if(!strcmp("instead",id))
			return "t";
    if(!strcmp("large",id))
			return "g";
    if(!strcmp("loop",id))
			return "w";
    if(!strcmp("make",id))
			return "m";
    if(!strcmp("number",id))
			return "#";
    if(!strcmp("other",id))
			return "o";
    if(!strcmp("real",id))
			return "x";
    if(!strcmp("repeat",id))
			return "j";
    if(!strcmp("select",id))
			return "h";
    if(!strcmp("small",id))
			return "p";
    if(!strcmp("step",id))
			return "c";
    if(!strcmp("stop",id))
			return "q";
    if(!strcmp("symbol",id))
			return "y";
    if(!strcmp("throw",id))
			return "z";

    //Operadores relacionales
    if(!strcmp("<",id))
			return "<";
    if(!strcmp(">",id))
			return ">";
    if(!strcmp("<=",id))
			return "l";
    if(!strcmp(">=",id))
			return "u";
    if(!strcmp("==",id))
			return "e";
    if(!strcmp("!=",id))
			return "d";
	return "";
}

//Funciones Genericas
void acepta(){
	printf("El codigo fuente fue analizado sintácticamente por completo.\n\n");
	return;
}

void error(){ 
	printf("Error Sintactico en atomo: [ %c ] con posicion de cadena: [ %d ]\n\n", cadena[indice-1], indice-1);
	return;
}

//Cadena resultante de atomos obtenidos de la listaAtomos
void getAtomo(){
	c = cadena[indice];
	indice++;
	return;
}

//Funciones ASD
void Program(){
	if(c == 'b' || c == 'g' || c == '#' || c == 'y' || c == 'x'){
		Func();
		otraFunc();
		return;
	}else{
		error();
		printf("Se esperaba un tipo de variable.\n");
	}
}

void otraFunc(){
	if(c == 'b' || c == 'g' || c == '#' || c == 'y' || c == 'x'){
		Func ();
		otraFunc();
		return;
	}else if(c = '0'){ //   0 representa fin de cadena 
		return;
	}else{
		error();
		printf("Se esperaba una identificador.\n");
	}
}

void Func(){
	if(c == 'b' || c == 'g' || c == '#' || c == 'y' || c == 'x'){
		Tipo();
		if(c=='i'){
			getAtomo();
		}else{
			error();
			printf("Se esperaba un identificador.\n");
		}
		if(c=='('){
			getAtomo();
		}else{
			error();
			printf("Se esperaba un '('.\n");
		}
		Param();
		if(c==')'){
			getAtomo();
		}else{
			error();
			printf("Se esperaba un ')'.\n");
		}if(c=='{'){
			getAtomo();
		}else{
			error();
			printf("Se esperaba un '{'.\n");
		}
		Cuerpo();
		if(c=='}'){
			getAtomo();
		}else{
			error();
			printf("Se esperaba un '}'.\n");
		}
		return;
	}else{
		error();
		printf("Se esperaba un tipo de variable.\n");
	}
}

void Param(){
	if(c == 'b' || c == 'g' || c == '#' || c == 'y' || c == 'x'){
		Tipo();
		if(c=='i'){
			getAtomo();
		}else{
			error();
			printf("Se esperaba un identificador.\n");
		}
		otroParam();
		return;
	}else if(c==')'){
		return;
	}else{
		error();
		printf("Se esperaba un tipo de variable o cierre de paréntesis ')'.\n");
	}
}

void otroParam(){
	if(c==','){
		getAtomo();
		Tipo();
		if(c=='i'){
			getAtomo();
		}else{
			error();
			printf("Se esperaba un identificador.\n");
		}
		otroParam();
		return;
	}else if(c==')'){
		return;
	}else{
		error();
		printf("Se esperaba una ',' o un ')'.\n");
	}
}

void Cuerpo(){
	if(c=='i'||c=='}'||c=='b'||c=='g'||c=='#'||c=='y'||c=='x'||c=='c'||c=='w'||c=='f'||c=='j'||c=='h'||c=='z'||c=='['){
		Decl();
		listaP();
		return;
	}else{
		error();
		printf("Se esperaba un identificador, un tipo de variable, un step, loop, evaluate, repeat, select, throw, '}' o '['.\n");
	}
}

void Decl(){
	if(c=='i'||c=='}'||c=='c'||c=='w'||c=='f'||c=='j'||c=='h'||c=='z'||c=='['){
		return;
	}else if(c=='b'||c=='g'||c=='#'||c=='y'||c=='x'){
		D();
		Decl();
		return;
	}else{
		error();
		printf("Se esperaba un identificador, un tipo de variable, un step, loop, evaluate, repeat, select, throw, '}' o '['.\n");
	}
}

void D(){
	if(c=='b'||c=='g'||c=='#'||c=='y'||c=='x'){
		Tipo();
		K();
		if(c==';'){
			getAtomo();
		}else{
			error();
			printf("Se esperaba un ';'.\n");
		}
		return;
	}else{
		error();
		printf("Se esperaba un tipo de variable.\n");
	}
}

void Tipo(){
	if(c=='b'){
		getAtomo();
		return;
	} else if(c=='g'){
		getAtomo();
		return;
	} else if(c=='#'){
		getAtomo();
		return;
	} else if(c=='y'){
		getAtomo();
		return;
	} else if(c=='x'){
		getAtomo();
		return;
	} else{
		error();
		printf("Se esperaba un tipo de variable.\n");
	}
}

void K(){
	if(c=='i'){
		getAtomo();
		Q();
		return;
	}else{
		error();
		printf("Se eperaba un identificador.\n");
	}
}

void Q(){
	if(c==';'){
		return;
	}else if(c=='='){
		getAtomo();
		N();
		C();
		return;
	}else if(c==','){
		getAtomo();
		K();
		return;
	}else{
		error();
		printf("Se esperaba un '=', ',' o un ';'.\n");
	}
}

void N(){
	if(c=='n'){
		getAtomo();
		return;
	}
	else if(c=='r'){
		getAtomo();
		return;
	}
	else if(c=='s'){
		getAtomo();
		return;
	}
	else{
		error();
		printf("Se esperaba alguna constante(cadena, entera o real)\n");
	}
}

void C(){
	if(c==';'){
		return;
	}
	else if(c==','){
		getAtomo();
		K();
		return;
	}
	else{
		error();
		printf("Se esperaba alguna ';' o ','\n");
	}
}

void A(){
	if(c=='i'){
		getAtomo();
		if(c=='='){
			getAtomo();
			AP();
			if(c==';'){
				getAtomo();
				return;
			}
			else{
				error();
				printf("Se esperaba un ';'\n");
			}
			//return;
		}
		else{
			error();
			printf("Se esperaba un '='\n");
		}
	}
	else{
		error();
		printf("Se esperaba una 'i'\n");
	}
}

void AP(){
	if(c=='s'){
		getAtomo();
		return;
	}
	else if(c=='('||c=='i'||c=='n'||c=='r'||c=='['){
		E();
		return;
	}
	else{
		error();
		printf("Se esperaba una asignación cadena o expresion\n");
	}
}

void E(){
	if(c=='('||c=='i'||c=='n'||c=='r'||c=='['){
		T();
		EP();
		return;
	}
	else{
		error();
		printf("Se espearaba un atomo 'c','i','n','r','['\n");
	}
}

void EP(){
	if(c=='+'){
		getAtomo();
		T();
		EP();
		return;
	}
	else if(c=='-'){
		getAtomo();
		T();
		EP();
		return;
	}
	else if(c==';'||c==')'){
		return;
	}
	else{
		error();
		printf("Se esperaba un operador arimetico o cierre de expresion o agrupacion\n");
	}
}

void T(){
	if(c=='('||c=='i'||c=='n'||c=='r'||c=='['){
		F();
		TP();
		return;
	}
	else{
		error();
		printf("Se esperaba una nueva expresion\n");
	}
}

void TP(){
	if(c=='*'){
		getAtomo();
		F();
		TP();
		return;
	}
	else if(c=='/'){
		getAtomo();
		F();
		TP();
		return;
	}
	else if(c=='\\'){ //revisar aqui
		getAtomo();
		F();
		TP();
		return;	
	}
	else if(c=='%'){
		getAtomo();
		F();
		TP();
		return;
	}
	else if(c=='^'){
		getAtomo();
		F();
		TP();
		return;
	}
	else if(c==';'||c==')'||c=='+'||c=='-'){
		return;
	}
	else{
		error();
		printf("Se esperaba un operador arimetico o cierre de expresion o agrupacion\n");

	}
}

void F(){
	if(c=='('){
		getAtomo();
		E();
		if(c==')'){
			getAtomo();
			return;
		}
		else{
			error();
			printf("Se esperaba un ')'\n");
		}
		return;
	}
	else if(c=='i'){
		getAtomo();
		return;
	}
	else if(c=='n'){
		getAtomo();
		return;
	}
	else if(c=='r'){
		getAtomo();
		return;
	}
	else if(c=='['){
		Llama();
		return;
	}
	else{
		error ();
		printf("Se esperaba un atomo '(','i','n','r','['\n");
	}
	
}

void R(){
	if(c=='i'){
		getAtomo();
		RP();
		V();
		return;
	}
	else if(c=='n'){
		getAtomo();
		RP();
		VP();
		return;
	}
	else if(c=='r'){
		getAtomo();
		RP();
		VPP();
		return;
	}
	else if(c=='s'){
		getAtomo();
		RP();
		VPPP();
	}
	else{
		error();
		printf("Se esperaba un atomo 'i','n','r','s'\n");
	}
}

void RP(){
	if(c=='>'){
		getAtomo();
		return;
	}
	else if(c=='<'){
		getAtomo();
		return;	
	}
	else if(c=='l'){
		getAtomo();
		return;
	}
	else if(c=='e'){
		getAtomo();
		return;
	}
	else if(c=='d'){
		getAtomo();
		return;
	}
	else if(c=='u'){
		getAtomo();
		return;
	}
	else{
		error();
		printf("Se esperaba un atomo '>','<','l','e','d','u'\n");
	}
}

void V(){
	if(c=='i'){
		getAtomo();
		return;
	}else if(c=='n'){
		getAtomo();
		return;
	}else if(c=='r'){
		getAtomo();
		return;
	}else if(c=='s'){
		getAtomo();
		return;
	}else{
		error();
		printf("Se esperaba una contante numérica entera, real o cadena.\n");
	}
}

void VP(){
	if(c=='n'){
		getAtomo();
		return;
	}else if(c=='i'){
		getAtomo();
		return;
	}else{
		error();
		printf("Se esperaba una constante numérica entera o identificador.\n");
	}
}

void VPP(){
	if(c=='r'){
		getAtomo();
		return;
	}else if(c=='i'){
		getAtomo();
		return;
	}else{
		error();
		printf("Se esperaba una constante numérica real o identificador.\n");
	}
}

void VPPP(){
	if(c=='s'){
		getAtomo();
		return;
	}else if(c=='i'){
		getAtomo();
		return;
	}else{
		error();
		printf("Se esperaba una constante cadena o identificador.\n");
	}
}

void P(){
	if(c=='i'){
		A();
		return;
	}else if(c=='f'){
		I();
		return;
	}else if(c=='h'){
		H();
		return;
	}else if(c=='w'){
		W();
		return;
	}else if(c=='j'){
		J();
		return;
	}else if(c=='['){
		Llama();
		return;
	}else if(c=='z'){
		Devuelve();
		return;
	}else if(c=='c'){
		getAtomo();
		if(c==';'){
			getAtomo();
		}else{
			error();
			printf("Se esperaba un ';'.\n");
		}
		return;
	}else{
		error();
		printf("Se esperaba un identificador, evaluate, select, loop, repeat, throw, step o '['.\n");
	}
}

void listaP(){
	if(c=='}'||c==':'||c=='t'||c=='a'||c=='o'||c=='q'){
		return;
	}else if(c=='i'||c=='c'||c=='w'||c=='f'||c=='j'||c=='h'||c=='z'||c=='['){
		P();
		listaP();
		return;
	}else{
		error();
		printf("Se esperaba un instead, alternative, other, stop, step, loop, evaluate, repeat, select, throw, un identificador, '}', ':' o un '['.\n");
	}
}

void W(){
	if(c=='w'){
		getAtomo();
		if(c=='('){
			getAtomo();
		}else{
			error();
			printf("Se esperaba un '('.\n");
		}
		R();
		if(c==')'){
			getAtomo();
		}else{
			error();
			printf("Se esperaba un ')'.\n");
		}
		if(c=='m'){
			getAtomo();
		}else{
			error();
			printf("Se esperaba un make.\n");
		}
		if(c=='{'){
			getAtomo();
		}else{
			error();
			printf("Se esperaba un '{'.\n");
		}
		listaP();
		if(c=='}'){
			getAtomo();
		}else{
			error();
			printf("Se esperaba un '}'.\n");
		}
		return;
	}else{
		error();
		printf("Se esperaba un loop.\n");
	}
}

void I(){
	if(c=='f'){
		getAtomo();
		if(c=='('){
			getAtomo();
		}else{
			error();
			printf("Se esperaba un '('.\n");
		}
		R();
		if(c==')'){
			getAtomo();
		}else{
			error();
			printf("Se esperaba un ')'.\n");
		}
		listaP();
		IP();
		if(c==':'){
			getAtomo();
		}else{
			error();
			printf("Se esperaba un ':'.\n");
		}
		return;
	}else{
		error();
		printf("Se esperaba un evaluate.\n");
	}
}

void IP(){
	if(c=='t'){
		getAtomo();
		listaP();
		return;
	}else if(c==':'){
		return;
	}else{
		error();
		printf("Se esperaba un instead o un ':'.\n");
	}
}

void J(){
	if(c=='j'){
		getAtomo();
		if(c=='('){
			getAtomo();
		}else{
			error();
			printf("Se esperaba un '('.\n");
		}
		Y();
		X();
		Z();
		if(c=='{'){
			getAtomo();
		}else{
			error();
			printf("Se esperaba un '{'.\n");
		}
		listaP();
		if(c=='}'){
			getAtomo();
		}else{
			error();
			printf("Se esperaba un '}'.\n");
		}
		return;
	}else{
		error();
		printf("Se esperaba un repeat.\n");
	}
}

void Y(){
	if(c=='i'){
		getAtomo();
		if(c=='='){
			getAtomo();
		}else{
			error();
			printf("Se esperaba un '='.\n");
		}
		E();
		if(c==';'){
			getAtomo();
		}else{
			error();
			printf("Se esperaba un ';'.\n");
		}
		return;
	}else if(c==';'){
		getAtomo();
        return;
	}else{
		error();
		printf("Se esperaba un identificador o ';'.\n");
	}
}

void X(){
	if(c=='i'||c=='n'||c=='r'||c=='s'){
		R();
		if(c==';'){
			getAtomo();
			return;
		}
		else{
			error();
			printf("Se esperaba un atomo ';'\n");
		}
	}
	else if(c==';'){
		getAtomo();
		return;
	}
	else{
		error();
		printf("Se esperaba un atomo 'i','n','r','s'\n");
	}
}

void Z(){
	if(c=='i'){
		getAtomo();
		if(c=='='){
			getAtomo();
			E();
			if(c==')'){
				getAtomo();
				return;
			}
			else{
				error();
				printf("Se esperaba un atomo ')'\n");
			}
		}
		else{
			error();
			printf("Se esperaba un atomo '='\n");
		}
	}
	else if(c==')'){
		getAtomo();
		return;
	}
	else{
		error();
		printf("Se esperaba un atomo 'i'\n");
	}
}

void H(){
	if(c=='h'){
		getAtomo();
		if(c=='('){
			getAtomo();
			if(c=='i'){
				getAtomo();
				if(c==')'){
					getAtomo();
					if(c=='{'){
                        getAtomo();
						CP();
						OP();
						if(c=='}'){
							getAtomo();
							return;
						}
						else{
							error();
							printf("Se esperaba un atomo '}'\n");
						}
					}
					else{
						error();
						printf("Se esperaba un atomo '{'\n");
					}
				}
				else{
					error();
					printf("Se esperaba un atomo ')'\n");
				}
			}
			else{
				error();
				printf("Se esperaba un atomo 'i'\n");
			}
		}
		else{
			error();
			printf("Se esperaba un atomo '('\n");
		}
	}
	else{
		error();
		printf("Se esperaba un atomo 'h'\n");
	}
}

void CP(){
	if(c=='a'){
		getAtomo();
		if(c=='n'){
			getAtomo();
			if(c==':'){
                getAtomo();
				listaP();
				U();
				CP();
				return;
			}
			else{
				error();
				printf("Se esperaba un atomo ':'\n");
			}
		}
		else{
			error();
			printf("Se esperaba un atomo 'n'\n");
		}
	}
	else if(c=='}'||c=='o'){
		return;
	}
	else{
		error();
		printf("Se esperaba un atomo 'a','}','o'\n");
	}
}

void OP(){
	if(c=='o'){
		getAtomo();
		if(c==':'){
            getAtomo();
			listaP();
			return;
		}
		else{
			error();
			printf("Se esperaba un atomo ':'\n");
		}
	}
	else if(c=='}'){
		return;
	}
	else{
		error();
		printf("Se esperaba un atomo 'o'\n");
	}
}

void U(){
	if(c=='q'){
		getAtomo();
		return;
	}
	else if(c=='}'||c=='a'||c=='o'){
		return;
	}
	else{
		error();
		printf("Se esperaba un atomo 'q' ó '}','a','o'\n");
	}
}

void Devuelve(){
	if(c=='z'){
		getAtomo();
		if(c=='('){
            getAtomo();
			valor();
			if(c==')'){
				getAtomo();
				if (c==';'){
					getAtomo();
					return;
				}
				else{
					error();
					printf("Se esperaba un atomo ';'\n");
				}
			}
			else{
				error();
				printf("Se esperaba un atomo ')'\n");
			}
		}
		else{
			error();
			printf("Se esperaba un atomo '('\n");
		}
	}
	else{
		error();
		printf("Se esperaba un atomo 'z'\n");
	}
}

void valor(){
	if(c=='i'||c=='n'||c=='r'||c=='s'){
		V();
		return;
	}
	else if(c==')'){
		return;
	}
	else{
		error();
		printf("Se esperaba un atomo ')' ó 'i','n','r','s'\n");	
	}
}

void Llama(){
	if(c=='['){
		getAtomo();
		if(c=='i'){
			getAtomo();
			if(c=='('){
                getAtomo();
				arg();
				if(c==')'){
					getAtomo();
					if(c==']'){
						getAtomo();
						return;
					}
					else{
						error();
						printf("Se esperaba un atomo ']'\n");
					}
				}
				else{
					error();
					printf("Se esperaba un atomo ')'\n");
				}
			}
			else{
				error();
				printf("Se esperaba un atomo '('\n");
			}
		}
		else{
			error();
			printf("Se esperaba un atomo 'i'\n");
		}
	}
	else{
		error();
		printf("Se esperaba un atomo '['\n");
	}
}

void arg(){
	if(c==')'){
		return;
	}else if(c=='i'||c=='n'||c=='r'||c=='s'){
		V();
		otroArg();
		return;
	}else{
		error();
		printf("Se esperana un identificador, constante numérica entera, real, cadena o ')'.n");
	}
}

void otroArg(){
	if(c==','){
		getAtomo();
		V();
		otroArg();
		return;
	}else if(c==')'){
		return;
	}else{
		error();
		printf("Se esperaba un ',' o ')'.\n");
	}
}

/*Funciones generalizadas*/
void abrirArchivos(){
    //Abriendo archivos.
    ArchGeneral = fopen("TokensGenerales.txt","w"); 
    ArchPalabrasReservadas = fopen("TablaPalabrasReservadas.txt","w");
    ArchIdentificadores = fopen("TablaIdentificadores.txt","w");
    //ArchEnterasOctales = fopen("TablaEnterosOctales.txt","w");
    ArchConsReales = fopen("TablaConsReales.txt","w");
    ArchCadenas = fopen("TablaCadenas.txt","w");
    ArchEspeciales = fopen("TablaSimbolosEspeciales.txt","w");
    ArchAritmeticos = fopen("TablaOperadoresArimeticos.txt","w");
    ArchRelacionales = fopen("TablaOperadoresRelacionales.txt","w");
    ArchNoReconocidos = fopen("CaracteresNoReconocidos.txt","w");
    //Archivo para guardar cadena de atomos
    ArchCadenaAtomos = fopen("CadenaAtomos.txt","w");
}

/*Funciones generalizadas*/
void imprimirAchivos(){
    //Ecribiendo archivo cadena átomos.
    fprintf(ArchCadenaAtomos,"Cadena de átomos:\n");
    fprintf(ArchCadenaAtomos,"%s",cadena);
    //Escribiendo archivos.
    printTablaReservadas();
	printTablaIdentificadores(listaIdentificadores);
	//printTabla(listaEnterasOctales, ArchEnterasOctales, "Enteros y octales");
	printTabla(listaReales, ArchConsReales, "Constantes reales");
    printTabla(listaCadenas, ArchCadenas, "Cadenas");
    printTablaEstatica(ArchEspeciales, "Caracteres especiales", tamanoEspecial, especial);
    printTablaEstatica(ArchAritmeticos, "Operadores aritméticos", tamanoAritmetico, aritmetico);
    printTablaEstatica(ArchRelacionales, "Operadores relacionales", tamanoRelacional, relacional);
}

void cerrarArchivos(){
    //Cerrando archivos
    fclose(ArchGeneral);
    fclose(ArchPalabrasReservadas);
    fclose(ArchIdentificadores);
    //fclose(ArchEnterasOctales);
    fclose(ArchConsReales);
    fclose(ArchCadenas);
    fclose(ArchEspeciales);
    fclose(ArchAritmeticos);
    fclose(ArchRelacionales);
    fclose(ArchNoReconocidos);
    fclose(ArchCadenaAtomos);
}