

# delete all saved results, scripts, and pdfs

delete_directories <- c("results", "scripts", "www")

for (del_dir in delete_directories){

  file.remove(file.path(del_dir, list.files(del_dir)))

}




