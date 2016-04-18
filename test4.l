
%{
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>

#define TABLE_SIZE 100
#define STD_STRING_LENGTH 50
  int flag = 0;
  int macro_ref=-1;
  int last_entry=0;
  char *name_tab[TABLE_SIZE];
  struct param_list{
  char *param_name;
  struct param_list* next;
  } *args_tab[TABLE_SIZE]={};
//  char unique_prefix[4]="AA";
  unsigned int unique_label_hex = 0x0000;
  struct definition
    {
     char *defline;
     struct definition *next;
    } *def_tab[TABLE_SIZE]={};
   
void displayerror(char *error)
{
  printf("\nError Occurred -> %s\n",error);
  exit(0);
} 
int macro_present(char *str)
  {
    int r=-1,i;
    for(i=0;i<last_entry;i++)
       {
         if(strcmp(str,name_tab[i])==0)
           {
              r=i;
              break;
            }
        }
     return r;
   }
void add_params(char* param,int loc)
  {
     struct param_list *link,*tab;
     
     link=(struct param_list*)malloc(sizeof(struct param_list));
     link->next=NULL;
     link->param_name=malloc(sizeof(char)*strlen(param));
     strcpy(link->param_name,param);
     tab=args_tab[loc];
     if(tab==NULL)
       {
           args_tab[loc]=link;
           return;
        }
     while(tab->next!=NULL)
       tab=tab->next;
     tab->next=link;
  }
int arg_count(int loc)
 {
     struct param_list *tab=args_tab[loc];
     int count=0;
     
     while(tab!=NULL)
       {
         count++;
         tab=tab->next;
       }  
     return count;
 }
char *replace_substring(char *search , char *replace , char *subject)
{
    char  *p = NULL , *old = NULL , *new_subject = NULL ;
    int c = 0 , search_size;
    search_size = strlen(search);
    for(p = strstr(subject , search) ; p != NULL ; p = strstr(p + search_size , search))
    {
        c++;
    }
    c = ( strlen(replace) - search_size )*c + strlen(subject);
    new_subject = malloc( c );
    strcpy(new_subject , "");
    old = subject;
    for(p = strstr(subject , search) ; p != NULL ; p = strstr(p + search_size , search))
    {
        strncpy(new_subject + strlen(new_subject) , old , p - old);
        strcpy(new_subject + strlen(new_subject) , replace);
        old = p + search_size;
    }
    strcpy(new_subject + strlen(new_subject) , old);
    return new_subject;
}
void display_params(int loc)
  {
     struct param_list *tab=args_tab[loc];
     int count = 0;
     while(tab!=NULL)
       {
	
	
     	if(count==0)
		printf("%s",tab->param_name);
	else
		printf(",%s",tab->param_name);
	 
	 count++;
         tab=tab->next;
       }  
     printf("\n");
  }
char *get_params(loc,y)
  {
    struct param_list *tab=args_tab[loc];
     int count=0;
     char *p=NULL;
     while(tab!=NULL)
       { 
       if(count==y)
       {
         p=(char*)malloc(strlen(tab->param_name)*sizeof(char));
         strcpy(p,tab->param_name);
         return p;
        }
       
       count++;
       tab=tab->next;
       }  
   }
char *replace_str(char *str, char *orig, char *rep)
{
    static char buffer[4096];
    char *p;
     
    if(!(p = strstr(str, orig)))
    return str;
     
    strncpy(buffer, str, p-str);
    buffer[p-str] = '\0';
     
    sprintf(buffer+(p-str), "%s%s", rep, p+strlen(orig));
     
    return buffer;
}
void add_def(char* def,int loc)
  {
     struct definition *link,*tab;
     
     link=(struct definition*)malloc(sizeof(struct definition));
     if(link==NULL)
       displayerror("Error creating new node in add_def");
     link->next=NULL;
     link->defline=malloc(sizeof(char)*strlen(def));
     if(link->defline==NULL)
       displayerror("Error creating new node in add_def");

     
     strcpy(link->defline,def);
     tab=def_tab[loc];
     if(tab==NULL)
       {   
          
           def_tab[loc]=link;
           return;
        }
     while(tab->next!=NULL)
       tab=tab->next;
     tab->next=link;
  }
void display_def(int loc)
  {
     struct definition *tab=def_tab[loc];
     int count=1;
     
     while(tab!=NULL)
       {       
       printf("%s \n\t",tab->defline);
       tab=tab->next;
       }  
     
  }

char *get_definition(loc,y)
  {
    struct definition *tab=def_tab[loc];
     int count=0;
     char *p=NULL;
     while(tab!=NULL)
       { 
       if(count==y)
       {
         p=(char*)malloc(strlen(tab->defline)*sizeof(char));
         strcpy(p,tab->defline);
         return p;
        }
       count++;
       tab=tab->next;
       }  
   }
void get_param_list(char*params,int loc)
{
  int i=0,n=strlen(params),r;
  char e[100];
  while(params[i]==' ')
      i++;
 
  
  while(i<=n)
  { 
    if(params[i]!=' '&&params[i]!=',')
      {
        r=0;
        while( params[i]!=' '&&params[i]!=','&&i<=n)
          {
            e[r]=params[i];
            r++;
            i++;
          }
       e[r]='\0';
     
       add_params(e,loc);
       
      }
    else
      {
        if(params[i]==' ')
          {
             while(params[i]==' ')
                 i++;
             if(params[i]!=',')
                displayerror("Error in detecting comma in get_params_list");
              i++;
            while(params[i]==' ')
                 i++;
  
          }
        else if(params[i]==',')
          {
            i++;
            while(params[i]==' ')
                 i++;
               

          }
        else
          displayerror("Character other than space and comma detected in get_params_list");
      }       
  }
}
void replace_with_macro(char *params,int loc,char *first_substring)
{
  int i=0,n=strlen(params),r,t=0;
  char e[100];
  char *list[100];
  while(params[i]==' '&&i<=n)
      i++;
   
  while(i<=n)
  {
    if(params[i]!=' '&&params[i]!=','&&params[i]!='\0'&&params[i]!='\n')
      {
        r=0;
        while( params[i]!=' '&&params[i]!=','&&params[i]!='\n'&&i<=n)
          {
            e[r]=params[i];
            r++;
            i++;
          }
       e[r]='\0';
	i++;
       list[t]=(char*)malloc(strlen(e)*sizeof(char));
       strcpy(list[t],e);
      t++;
      }
    else
      {
        if(params[i]==' ')
          {
             while(params[i]==' ')
                 i++;
             if(params[i]!=',')
                displayerror("macro replace error");
              i++;
            while(params[i]==' ')
                 i++;
  
          }
        else if(params[i]==',')
          {
            i++;
            while(params[i]==' ')
                 i++;
          }
        else if(params[i]=='\0'||params[i]=='\n')
            break;       
        else
          displayerror("Invalid character error");
      }       
  }
  int z=arg_count(loc);
  if(z!=t)
    {
      char x[100];
      sprintf(x,"Arguments mismatch for macro %s",first_substring);
      displayerror(x);
     }
  else
    {
     
     char *a=NULL;
     char *str=NULL,m[100],original_param[100];
     int y=0;
     int temp_i=0,temp_n=0,temp_loc;
     char temp_first_substring[100]={};
     while((a=get_definition(loc,y))!=NULL)
       {

        /* Generation of unique labels - Start*/
        char *pos_label;    
        char *temp;
        int i=0,pos=-1,j;
        pos_label=strchr(a,':');    
        if(pos_label!=NULL)
         {
            for(i=0;i<strlen(a);i++)
            {
              if(a[i]==':')
              {
                pos++;
                break;
              }
              else
                pos++;
            }
            char unique_label1[100],unique_label2[100],label[100];    
            strcpy(unique_label1,"??");
            sprintf(unique_label2,"0x%04X",unique_label_hex);
            for(i=2;i<strlen(unique_label2);i++)
            {
              unique_label2[i-2]=unique_label2[i];
            }
            unique_label2[i-2]='\0';
            unique_label_hex+=1;
            for(i=0;i<pos;i++)      
            {                  
              label[i]=a[i];            
            } 
            label[i]='\0';
            strcat(unique_label1,unique_label2);
            a=replace_str(a,label,unique_label1);  
         }
       /* Generation of unique labels - End*/

        /* Nested macro expansion - Start*/
        temp_n=0;
        if(pos_label!=NULL)
        {
          while(a[temp_n]!=':')
            temp_n++;
          temp_n++;
        }
        while(a[temp_n]==' ')
        {
          temp_n++;                      
        }        
        temp_i=0;
        unsigned int temp_macro_len=strlen(a);
        for(temp_i=0;temp_i<strlen(a);)
        {
          if(a[temp_n]!=' '&&a[temp_n]!=','&&a[temp_n]!='\n')
          {
            temp_first_substring[temp_i++]=a[temp_n++];
          }
          else
            break;
        }        
        if((temp_loc=macro_present(temp_first_substring))>-1)
        {
          replace_with_macro(a+temp_n,temp_loc,temp_first_substring);     
        }   
        /* Nested macro expansion - End*/     
        else
        {
         for(i=0;i<t;i++)
           {
            str=get_params(loc,i);
            
            strcpy(original_param,str);
            
            a=replace_substring(original_param,list[i],a);
           }
         fprintf(yyout,"%s",a);
         fprintf(yyout,"\n");
       }
        y++;
       }          
     }
}
%}
%%
^[ ]*("endm"|"ENDM") { 

       if(flag==1)
           {
            flag=0; 
           }
        else
           {
             displayerror("Detected endm before detecting macro name");
           }      
         }
     
     
^([ ]*)[a-zA-Z][a-zA-Z0-9]*([ ]*)macro[a-zA-Z0-9, ]* {
                                             if(flag==0)
                                              {
                                               
                                               flag=1;
                                               int i,j,k,l,m,n;
                                               n=0;
                                               char name[100]={};
                                               
                                               while(yytext[n]==' ')
                                                  n++;
                                                
                                              l=0;
                                               while(yytext[n]!=' ')
                                                  name[l++]=yytext[n++];
                                               name[l]='\0';
                                               
                                               macro_ref=last_entry;
                                               last_entry++;
                                               name_tab[macro_ref]=malloc(sizeof(char)*l);
                                               strcpy( name_tab[macro_ref],name);
                                               while(yytext[n]==' ')
                                                  n++;
                                               char macrostring[6]="macro";
                                               j=0;
                                               
                                               for(i=0;i<5;i++)
                                                 {
                                                   
                                                     if(tolower(macrostring[i])!=tolower(yytext[n+i]))
                                                         {
                                                            
                                                             j++;
                                                             break;
                                                          } 
                                                    
                                                  }
                                               if(j!=0)
                                                  displayerror("Error in detecting the \"MACRO\" word in the macro prototype");
                                               n+=5;          
                                               while(yytext[n]==' ')
                                                  n++;
                                               
                                               if(n<strlen(yytext))
                                                if(strlen(yytext+n)>0)
                                                   get_param_list(yytext+n,macro_ref);
                                               
                                               }
                                            
                                             else 
                                              {
                                               displayerror("Unknown flag Detected in the macro prototype");

                                              }

                                           }  

     
^(.)*                                       {
                                            if(flag==0)
                                              {
                                                char first_substring[100]={};
                                                int n=0,i,j,k,l,m,loc=-1;
                                                while(yytext[n]==' ')
                                                  n++;
                                                i=0;
                                                while(yytext[n]!=' '&&yytext[n]!=','&&yytext[n]!='\n')
                                                    first_substring[i++]=yytext[n++];
                                                if((loc=macro_present(first_substring))>-1)
                                                  {
                                                    replace_with_macro(yytext+n,loc,first_substring);     
                                                  }
                                                else
                                                 {
                                                   fprintf(yyout,"%s",yytext);
                                                   fprintf(yyout,"\n");
                                                  }          
                                               }
                                             else if(flag==1)
                                               {
                                                 add_def(yytext,macro_ref);
                                               }
                                             else 
                                              {
                                               displayerror("Unknown flag Detected in the macro prototype search");

                                              }

                                           } 
                                           





\n {};



%%

main ()
{
         int i=0;
         for(i=0;i<100;i++)
             {
               args_tab[i]=NULL;
               def_tab[i]=NULL;
             }   
        char inputfile[100] ="input.txt", outputfile[100] = "output.txt";
	printf ("\tOne Pass Macro Processor for 8086 \n");
	printf (" Enter the name of the input file : ");
//	scanf ("%s",inputfile);
	printf ("Input file : %s \n",inputfile);
	printf ("Output file : %s \n",outputfile);
	yyin = fopen (inputfile, "r");
	yyout = fopen (outputfile, "w");
	yylex ();
         int cn,r;
	printf("------------NAMTAB-----------\n");
	printf("Index\t    Macro_name\n");
        for(cn=0;cn<last_entry;cn++)
        {
	r=cn+1;
	printf("%d\t\t%s\n",r,name_tab[cn]);
}
printf("------------ARGTAB-----------\n");
	printf("Index\tARG_LIST\n");
        for(cn=0;cn<last_entry;cn++)
        {
	printf("%d\t",cn+1);
	display_params(cn);
}
printf("------------DEFTAB-----------\n");
	printf("Index\t Macro_definition\n");
        for(cn=0;cn<last_entry;cn++)
        {
	printf("%d\t",cn+1);
	display_def(cn);
	printf("\n");
}
printf("-----------------------------\n");
}
yywrap ()
{
return 1;}

	    
