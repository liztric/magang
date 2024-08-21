<!DOCTYPE html>
<html lang="en">
<head>
  <!-- Required meta tags -->
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />

  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous" />
  <link rel="stylesheet" href="style.css">
  <title>Security System</title>
  <style>
    /* CSS tambahan untuk menyesuaikan lebar kolom dan tampilan tombol */
    table {
      width: 100%;
    }
    th, td {
      text-align: center;
      vertical-align: middle; /* Menjaga agar konten tetap di tengah vertikal */
    }
    .action-buttons {
      display: flex;
      justify-content: center;
      gap: 0.5rem; /* Menambahkan jarak antara tombol */
    }
    .btn {
      margin: 0; /* Menghapus margin default jika ada */
      transition: transform 0.2s ease, opacity 0.2s ease; /* Tambahkan animasi pada transformasi dan opacity */
    }
    .btn:active {
      transform: scale(0.95); /* Efek mengecil saat ditekan */
      opacity: 0.7; /* Efek mengurangi opacity saat ditekan */
    }
    .error-message {
      color: red;
      font-size: 0.875rem;
    }
  </style>
</head>
<body>
  <!-- Navbar -->
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container-fluid">
      <div class="collapse navbar-collapse" id="navbarNavDropdown">
        <ul class="navbar-nav">
          <li class="nav-item">
            <a class="nav-link" href="index">Home</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="register">Register</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="daftaruser">Daftar Pengguna</a>
          </li>
        </ul>
      </div>
    </div>
  </nav>

  <div class="container mt-5">
    <h1>Security System</h1>
    <div class="table-responsive">
      <table class="table table-striped">
        <thead>
          <tr>
            <th scope="col">No</th>
            <th scope="col">Nama</th>
            <th scope="col">Username</th>
            <th scope="col">Password</th>
            <th scope="col">Alamat</th>
            <th scope="col">Role</th> <!-- Tambahkan kolom Role -->
            <th scope="col">Aksi</th>
          </tr>
        </thead>
        <tbody id="tbody"></tbody>
      </table>
    </div>
  </div>

  <!-- Modal edit data -->
  <div class="modal fade" id="exampleModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="exampleModalLabel">Edit Data</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label for="editnama" class="form-label">Nama</label>
            <input type="text" class="form-control" id="editnama" />
          </div>
          <div class="mb-3">
            <label for="editusername" class="form-label">Username</label>
            <input type="text" class="form-control" id="editusername" />
            <div id="editusernameError" class="error-message"></div>
          </div>
          <div class="mb-3">
            <label for="editpassword" class="form-label">Password</label>
            <input type="text" class="form-control" id="editpassword" />
          </div>
          <div class="mb-3">
            <label for="editalamat" class="form-label">Alamat</label>
            <input type="text" class="form-control" id="editalamat" />
          </div>
          <fieldset class="mb-3">
            <legend class="col-form-label">Role</legend>
            <div class="form-check">
              <input class="form-check-input" type="radio" name="editrole" id="roleSatpam" value="satpam" />
              <label class="form-check-label" for="roleSatpam">Satpam</label>
            </div>
            <div class="form-check">
              <input class="form-check-input" type="radio" name="editrole" id="roleWarga" value="warga" />
              <label class="form-check-label" for="roleWarga">Warga</label>
            </div>
          </fieldset>
          <input type="hidden" id="getid" />
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          <button type="button" class="btn btn-primary" id="updateData" onclick="updateData()">Save changes</button>
        </div>
      </div>
    </div>
  </div>

  <!-- Modal tambah data -->
  <div class="modal fade" id="addDataModal" tabindex="-1" aria-labelledby="addDataModalLabel" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="addDataModalLabel">Add Data</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label for="nama" class="form-label">Nama</label>
            <input type="text" class="form-control" id="nama" />
          </div>
          <div class="mb-3">
            <label for="username" class="form-label">Username</label>
            <input type="text" class="form-control" id="username" />
            <div id="usernameError" class="error-message"></div>
          </div>
          <div class="mb-3">
            <label for="password" class="form-label">Password</label>
            <input type="text" class="form-control" id="password" />
          </div>
          <div class="mb-3">
            <label for="alamat" class="form-label">Alamat</label>
            <input type="text" class="form-control" id="alamat" />
          </div>
          <fieldset class="mb-3">
            <legend class="col-form-label">Role</legend>
            <div class="form-check">
              <input class="form-check-input" type="radio" name="role" id="roleSatpam" value="satpam" />
              <label class="form-check-label" for="roleSatpam">Satpam</label>
            </div>
            <div class="form-check">
              <input class="form-check-input" type="radio" name="role" id="roleWarga" value="warga" />
              <label class="form-check-label" for="roleWarga">Warga</label>
            </div>
          </fieldset>
          <div id="createError" class="error-message"></div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          <button type="button" class="btn btn-primary" id="createData" onclick="createData()">Save changes</button>
        </div>
      </div>
    </div>
  </div>

  <script>
    let namaV = document.getElementById("nama");
    let usernameV = document.getElementById("username");
    let passwordV = document.getElementById("password");
    let alamatV = document.getElementById("alamat");
    let tbody = document.getElementById("tbody");
    let editnama = document.getElementById("editnama");
    let editusername = document.getElementById("editusername");
    let editpassword = document.getElementById("editpassword");
    let editalamat = document.getElementById("editalamat");
    let roleSatpam = document.getElementById("roleSatpam");
    let roleWarga = document.getElementById("roleWarga");
    let getid = document.getElementById("getid");
    let usernameError = document.getElementById("usernameError");
    let createError = document.getElementById("createError");

    document.addEventListener("DOMContentLoaded", function () {
      getData();
    });

    function getData() {
      fetch("https://esolusindosecurity-default-rtdb.firebaseio.com/user.json?auth=05xW10cmdxUBIBwXw4i5edLZy06MbpMRelL5QGf2")
        .then((res) => res.json())
        .then((data) => {
          let tabel = "";
          let no = 1;
          let output = Object.entries(data);

          output.forEach((row) => {
            if (row[1] !== null) {
              let nama = row[1].nama || "N/A";
              let username = row[1].username || "N/A";
              let password = row[1].password || "N/A";
              let alamat = row[1].alamat || "N/A";
              let role = row[1].role || "N/A"; // Tambahkan role

              tabel += `
                <tr>
                  <td>${no}</td>
                  <td>${nama}</td>
                  <td>${username}</td>
                  <td>${password}</td>
                  <td>${alamat}</td>
                  <td>${role}</td> <!-- Tambahkan kolom role ke dalam tabel -->
                  <td class="action-buttons">
                    <button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#exampleModal" onclick="editRow('${row[0]}')">Edit</button>
                    <button type="button" class="btn btn-danger" onclick="deleteRow('${row[0]}')">Hapus</button>
                  </td>
                </tr>
              `;
              no++;
            }
          });

          tbody.innerHTML = tabel;
        });
    }

  
    function editRow(id) {
      fetch("https://esolusindosecurity-default-rtdb.firebaseio.com/user/" + id + ".json?auth=05xW10cmdxUBIBwXw4i5edLZy06MbpMRelL5QGf2")
        .then((res) => res.json())
        .then((data) => {
          editnama.value = data.nama;
          editusername.value = data.username.startsWith('@') ? data.username : '@' + data.username;
          editpassword.value = data.password;
          editalamat.value = data.alamat;
          if (data.role === "Satpam") {
            roleSatpam.checked = true;
          } else if (data.role === "Warga") {
            roleWarga.checked = true;
          }
          getid.value = id;
        });
    }

    function updateData() {
      let role = document.querySelector('input[name="editrole"]:checked').value;
      let username = editusername.value.trim();
      let putdata = {
        nama: editnama.value,
        username: username.startsWith('@') ? username : '@' + username,
        password: editpassword.value,
        alamat: editalamat.value,
        role: role // Sertakan role saat memperbarui data
      };

      if (!username.startsWith('@')) {
        document.getElementById('editusernameError').textContent = "Username harus dimulai dengan '@'.";
        return;
      }

      fetch("https://esolusindosecurity-default-rtdb.firebaseio.com/user/" + getid.value + ".json?auth=05xW10cmdxUBIBwXw4i5edLZy06MbpMRelL5QGf2", {
        method: "PUT",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify(putdata)
      })
        .then((res) => res.json())
        .then(() => {
          getData();
          // Tutup modal setelah pembaruan
          let modal = bootstrap.Modal.getInstance(document.getElementById('exampleModal'));
          modal.hide();
        });
    }

    function deleteRow(id) {
      fetch("https://esolusindosecurity-default-rtdb.firebaseio.com/user/" + id + ".json?auth=05xW10cmdxUBIBwXw4i5edLZy06MbpMRelL5QGf2", {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json"
        }
      })
        .then(() => {
          getData();
        });
    }
  </script>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>
</body>
</html>
