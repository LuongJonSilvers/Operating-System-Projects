#include <stdio.h>
#include "ext2_fs.h"
#include "read_ext2.h"
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdbool.h>
char *itoa(int val, int base)
{

	static char buf[32] = {0};

	int i = 30;

	for (; val && i; --i, val /= base)

		buf[i] = "0123456789abcdef"[val % base];

	return &buf[i + 1];
}
int main(int argc, char **argv)
{
	
	if (argc != 3)
	{
		printf("expected usage: ./runscan inputfile outputfile\n");
		exit(0);
	}
char *argtwo = argv[2];
	int fd;

	fd = open(argv[1], O_RDONLY); /* open disk image */

	ext2_read_init(fd);
	int retMkdir = mkdir(argv[2], S_IRWXU | S_IRWXG | S_IRWXO);
	if (retMkdir != 0)
	{
		return -1;
	}
	// printf("numgroups=%d",num_groups);
	//  bool doubleB = false;
	//  bool singleB = false;
	for (unsigned int g = 0; g < num_groups; g++)
	{
		struct ext2_super_block super;
		struct ext2_group_desc group;

		// example read first the super-block and group-descriptor
		read_super_block(fd, g, &super);
		read_group_desc(fd, g, &group);
		// inodes-pergroup
		// printf("There are %u inodes in an inode table block and %u blocks in the idnode table\n", inodes_per_block, itable_blocks);
		// iterate the first inode block
		off_t start_inode_table = locate_inode_table(g, &group);

		for (unsigned int ipg = 0; ipg < inodes_per_group; ipg++)
		{ // inodes_per_group

			struct ext2_inode *inode = malloc(sizeof(struct ext2_inode));
			// 	off_t newOffset = start_inode_table+(sizeof(inode))*ipg;
			//     lseek(fd, newOffset, SEEK_SET);
			// read(fd, inode, sizeof(inode));
			read_inode(fd, g, start_inode_table, ipg, inode);

			/* the maximum index of the i_block array should be computed from i_blocks / ((1024<<s_log_block_size)/512)
			 * or once simplified, i_blocks/(2<<s_log_block_size)
			 * https://www.nongnu.org/ext2-doc/ext2.html#i-blocks
			 */
			// unsigned int i_blocks = inode->i_blocks/(2<<super.s_log_block_size);
			//  printf("number of blocks %u\n", i_blocks);
			//  printf("Is directory? %s \n Is Regular file? %s\n",
			//     S_ISDIR(inode->i_mode) ? "true" : "false",
			//     S_ISREG(inode->i_mode) ? "true" : "false");
			if (S_ISREG(inode->i_mode))
			{
				char buffer[1024];
				int readAmount = 1024;
				// printf("inode size=%d\n\n",inode->i_size);
				if (inode->i_size < 1024)
				{ // jpg = 775
					readAmount = inode->i_size;
				}
				lseek(fd, BLOCK_OFFSET(inode->i_block[0]), SEEK_SET);
				read(fd, buffer, readAmount); // read first block size
				// printf("bytes=%d\n",readAmount);

				int is_jpg = 0;
				if (buffer[0] == (char)0xff &&
					buffer[1] == (char)0xd8 &&
					buffer[2] == (char)0xff &&
					(buffer[3] == (char)0xe0 ||
					 buffer[3] == (char)0xe1 ||
					 buffer[3] == (char)0xe8))
				{
					is_jpg = 1;
					// printf("FOUND JPG!!!!!!!!!!!!!!!!!!");
				}
				else
				{
					continue;
				}

				char *inode_char;
				inode_char = itoa(ipg, 10);
				printf("inode %d in group %d is jpg", ipg, g);

				// printf("inode char = %s\n",inode_char);
				if (is_jpg == 1)
				{
					char *argtwo = argv[2];
					char filename[256];
					memset(filename, 0, 256);
					strncpy(filename, argtwo, strlen(argtwo));

					// strcat(,argv[2]);
					// printf("argtwo = %s\n",filename);
					strcat(filename, "/file-");
					strcat(filename, inode_char);
					strcat(filename, ".jpg");
					// printf(">>>>>>>%s<<<<<<<",filename);

					// system("ls");
					if (inode->i_size == 0)
					{
						goto LABELOUT;
					}
					int ourFile = open(filename, O_WRONLY | O_TRUNC | O_CREAT, 0666);
					// 			if( ourFile == -1 ) {
					//       		perror("Error: ");
					//       	return(-1);
					//    }
					printf("ourFile fd : %d\n", ourFile);
					// print i_block numberss
					int full_reads = inode->i_size / 1024;
					int last_data_remain = inode->i_size % 1024;
					printf("inodeSz: %d,full reads=%d, partial read bytes=%d\n", inode->i_size, full_reads, last_data_remain);

					for (unsigned int i = 0; i < EXT2_N_BLOCKS; i++) //i-12 direct blocks, indirect, double, triple
					{
						if (i < EXT2_NDIR_BLOCKS)
						{ /* direct blocks */
							if (full_reads > 0)
							{ // jpg full 1024 block
								lseek(fd, BLOCK_OFFSET(inode->i_block[i]), SEEK_SET);
								read(fd, buffer, 1024);
								write(ourFile, buffer, 1024);
								// printf("Block %2u : %u\n", i, inode->i_block[i]);
								full_reads = full_reads - 1;
							}
							else
							{
								if (last_data_remain != 0)
								{
									lseek(fd, BLOCK_OFFSET(inode->i_block[i]), SEEK_SET);
									read(fd, buffer, last_data_remain);
									write(ourFile, buffer, last_data_remain);
									last_data_remain = 0;
								}
								else
								{ // done

									continue;
								}
							}
						}
						else if (i == EXT2_IND_BLOCK)
						{ /* single indirect block */ // i = 12 because indirect blocks i =12
							// singleB = true;
							for (int Sind = 0; Sind < 256; Sind++)
							{
								if (full_reads > 0)
								{ // jpg full 1024 block
									unsigned int address;
									lseek(fd, BLOCK_OFFSET(inode->i_block[i]) + 4 * Sind, SEEK_SET);
									read(fd, &address, 4);
									lseek(fd, BLOCK_OFFSET(address), SEEK_SET);
									read(fd, buffer, 1024);
									write(ourFile, buffer, 1024);

									printf("Block %2u : %u\n", i, inode->i_block[i]);
									printf("Single   : %u\n", inode->i_block[i]);
									full_reads = full_reads - 1;
								}
								else
								{
									if (last_data_remain != 0)
									{
										unsigned int address;
										lseek(fd, BLOCK_OFFSET(inode->i_block[i]) + 4 * Sind, SEEK_SET);
										read(fd, &address, 4);
										lseek(fd, BLOCK_OFFSET(address), SEEK_SET);
										read(fd, buffer, last_data_remain);
										write(ourFile, buffer, last_data_remain);

										last_data_remain = 0;
									}
									else
									{ // done
										// close(ourFile);
										goto LABELOUT;
									}
								}
							}
							// printf("Single   : %u\n", inode->i_block[i]);
						}
						else if (i == EXT2_DIND_BLOCK)
						{ // double indirect block for 4k imageee
							// doubleB = true;
							//printf("Double indirect Block %2u : %u\n", i, inode->i_block[i]);
							for (int Tind = 0; Tind < 256; Tind++)
							{
								for (int Sind = 0; Sind < 256; Sind++)
								{
									if (full_reads > 0)
									{ // jpg full 1024 block
										unsigned int address;
										lseek(fd, BLOCK_OFFSET(inode->i_block[i]) + 4 * Tind, SEEK_SET);
										read(fd, &address, 4);
										lseek(fd, BLOCK_OFFSET(address) + 4 * Sind, SEEK_SET);
										read(fd, &address, 4);
										lseek(fd, BLOCK_OFFSET(address), SEEK_SET);
										read(fd, buffer, 1024);
										write(ourFile, buffer, 1024);

										//printf("Double indirect Block %2u : %u\n", i, inode->i_block[i]);
										full_reads = full_reads - 1;
									}
									else
									{
										if (last_data_remain != 0)
										{
											//printf("Double indirect Block %2u : %u\n", i, inode->i_block[i]);
											unsigned int address;
											lseek(fd, BLOCK_OFFSET(inode->i_block[i]) + 4 * Tind, SEEK_SET);
											read(fd, &address, 4);
											lseek(fd, BLOCK_OFFSET(address) + 4 * Sind, SEEK_SET);
											read(fd, &address, 4);
											lseek(fd, BLOCK_OFFSET(address), SEEK_SET);
											read(fd, buffer, last_data_remain);
											write(ourFile, buffer, last_data_remain);
											last_data_remain = 0;
										}
										else
										{ // done
											// close(ourFile);
											goto LABELOUT;
										}
									}
								}
							}
						}							   /* double indirect block */
													   // printf("Double   : %u\n", inode->i_block[i]);
						else if (i == EXT2_TIND_BLOCK) /* triple indirect block */
							printf("Triple   : %u\n", inode->i_block[i]);
					}
				LABELOUT:
					fsync(ourFile);
					printf("closing file\n\n");
					close(ourFile);
				}
			}

			free(inode);
		}
		for (unsigned int ipg = 0; ipg < inodes_per_group; ipg++)
		{ // inodes_per_group

			struct ext2_inode *inode = malloc(sizeof(struct ext2_inode));
			// 	off_t newOffset = start_inode_table+(sizeof(inode))*ipg;
			//     lseek(fd, newOffset, SEEK_SET);
			// read(fd, inode, sizeof(inode));
			read_inode(fd, g, start_inode_table, ipg, inode);

			if (S_ISDIR(inode->i_mode))
			{
				int dir = 24; 
				char *inode_charD;
				inode_charD = itoa(ipg, 10);

				
				char filename[256];
				char outputDir[256];
				//printf("OUTSIDEargtwo=%s>\n", argtwo);

				memset(filename, 0, 256);				   // clear filename
				strncpy(filename, argtwo, strlen(argtwo)); // copy filename from arg2
				memset(outputDir, 0, 256);				   // clear outputDir
				strncpy(outputDir, argtwo, strlen(argtwo));
				// strcat(,argv[2]);
				// printf("argtwo = %s\n",filename);
				strcat(filename, "/file-");	   // filename = output_t6/file-
				strcat(filename, inode_charD); // filename = output_t6/file-11
				strcat(filename, ".jpg");	   // filename = output_t6/file-11.jpg
				//printf("filename[%s]<<indirectory", filename);
				// int dir = 0;
				char buffer[1024];

				// unsigned int address;
				lseek(fd, BLOCK_OFFSET(inode->i_block[0]), SEEK_SET);
				read(fd, buffer, 1024);
				//int i;
// for (i = 0; i < 1024; i++)
// {
//     printf("%02X", buffer[i]);
// }
// printf("\n");
				// printf("Directory name is >>%s<<\n",name);
				while (dir < 1024) //file-12 file-13
				 //cmd = cp output_t1/file-12 output_t1/a.jpg
				//cmd = cp output_t1/file-13 output_t1/b.jpg
				{ //sargtwo_copy = strdup(argtwo)
 					printf("\ndir is (%d)\n", dir);
					bool callDelete = false;
					char command[1024];
					char filenameD[256]; // ./executable img1 output_t1 -> /output_t1/file-11.jpg    a.jpg
					memset(filenameD, 0, 256);					// clear filenameD
					strncpy(filenameD, argtwo, strlen(argtwo)); // filenameD="output_t1"
					memset(command, 0, 1024);					// clear command
					strcat(filenameD, "/file-");				// filenameD = "output_t1/file-"
					strcat(command, "cp ");						// command="cp "
					strcat(command, filenameD);					// command = "cp output_t1/file-"
					//printf("\n>>%s<<filenameD\n", filenameD);

					//printf("THIS inode (%d) is a DIRECTORY w/ offset = %d\n", ipg, dir);
					/////undeleted
					struct ext2_dir_entry_2 *dentry;
					dentry = (struct ext2_dir_entry_2 *)&(buffer[dir]);
					int name_len = dentry->name_len & 0xFF; // convert 2 bytes to 4 bytes properly
					char name[EXT2_NAME_LEN];
					strncpy(name, dentry->name, name_len);
					name[name_len] = '\0';
					///////////////////////
					/////
					//////////////////deleted
					int dirDEL = dir + 8 + (dentry->name_len) + (dentry->name_len % 4);
					printf("dir+8+dir->name_lenMOD4,(%d)+8+(%d)+(%d)", dir, dentry->name_len, dentry->name_len % 4);
					struct ext2_dir_entry_2 *dentryDEL;
					dentryDEL = (struct ext2_dir_entry_2 *)&(buffer[dirDEL]);
					int name_lenDEL = dentryDEL->name_len & 0xFF; // convert 2 bytes to 4 bytes properly
					char nameDEL[name_lenDEL];
					strncpy(nameDEL, dentryDEL->name, name_lenDEL);
					nameDEL[name_lenDEL] = '\0';
					/////////////////////////////
					if (name_lenDEL != 0)
					{
						callDelete = true;
					}
					printf("_%d_name\n", name_lenDEL);
					// printf("DELETED Entry name is --%s--", nameDEL);
					if(callDelete)
					printf("DELETED Entry name(%s)EntLength(%d)NameLength(%d)CurOffset(%d)EntInode(%d)\n", nameDEL, dentryDEL->rec_len, dentryDEL->name_len, dirDEL, dentryDEL->inode);

					 printf("Entry name is --%s-- with entLength(%d)nameLength(%d)\n\n", name, dentry->rec_len,dentry->name_len);
					//  if((unsigned int)dentry->inode==ipg){
					//  	printf("FOUND ENTRY --%s-- with ipg(%d)dentry->inode(%d)\n\n", name, ipg,dentry->inode);
					//  }
					//  if(strcmp(name,"a.jpg")==0){
					//  //break;
					//  }
					//printf("IPG(%d)]\n", ipg);
					//printf("Entry name(%s)EntLength(%d)NameLength(%d)CurOffset(%d)EntInode(%d)\n", name, dentry->rec_len, dentry->name_len, dir, dentry->inode);
					char *entry_inode;
					entry_inode = itoa(dentry->inode, 10);
					strcat(command, entry_inode);
					strcat(command, ".jpg ");
					strcat(command, outputDir);
					strcat(command, "/'");
					strcat(command, name);
					strcat(command,"'");
					printf("\n>>%s<<ActTcomand\n", command);
					if (name_len != 0)
					{
						system(command);
					}

					if (callDelete)
					{
						printf("\nQWERT!!@#!@$!@$!\n");
						char commandDEL[256];
						char *entry_inodeDEL;
						entry_inodeDEL = itoa(dentryDEL->inode, 10);
						memset(commandDEL, 0, 256); // clear command
						// strncpy(commandDEL,argtwo,strlen(argtwo)); //filenameD="output_t1"
						strcat(commandDEL, "cp ");			// commandDEL="cp "
						strcat(commandDEL, filenameD);		// commandDEL= "cp output_t1/file-"
						strcat(commandDEL, entry_inodeDEL); // commandDEL= "cp output_t1/file-11"
						strcat(commandDEL, ".jpg ");		// commandDEL= "cp output_t1/file-11.jpg "
						strcat(commandDEL, outputDir);		// commandDEL= "cp output_t1/file-11.jpg output_t1"
						strcat(commandDEL, "/");
						strcat(commandDEL, nameDEL);
						printf("DELETEION COM(%s)", commandDEL);
						system(commandDEL);
					}
					printf("\n$$$addingtodir(%d),rec_len(%d)$$$<", dir, dentry->rec_len);
					dir = dir + dentry->rec_len;
				}
				printf("EXITING\n");
			}

			free(inode);
		}
	}
	close(fd);
}
