// Fetch elements
let namaV = document.getElementById("nama");
let usernameV = document.getElementById("username");
let passwordV = document.getElementById("password");
let alamatV = document.getElementById("alamat");
let tbody = document.getElementById("tbody");

let editnama = document.getElementById("editnama");
let editusername = document.getElementById("editusername");
let editpassword = document.getElementById("editpassword");
let editalamat = document.getElementById("editalamat");
let editrole = document.querySelectorAll('input[name="editrole"]'); // Ambil elemen role yang akan di-edit
let getid = document.getElementById("getid");

// Initialize
document.addEventListener("DOMContentLoaded", function () {
    getData();
    document.getElementById("registerForm").addEventListener("submit", function(event) {
        event.preventDefault(); // Prevent the default form submission
        checkUsernameAndCreateData(); // Call the checkUsernameAndCreateData function
    });
});

function getData() {
    fetch("https://esolusindosecurity-default-rtdb.firebaseio.com/user.json?auth=05xW10cmdxUBIBwXw4i5edLZy06MbpMRelL5QGf2")
        .then((res) => res.json())
        .then((data) => {
            let tabel = "";
            let no = 1;
            let output = Object.entries(data);
            output.forEach((row) => {
                tabel += `
                <tr>
                    <td>${no}</td>
                    <td>${row[1].nama}</td>
                    <td>${row[1].username}</td>
                    <td>${row[1].password}</td>
                    <td>${row[1].alamat}</td>
                    <td>${row[1].role}</td> <!-- Tampilkan role di tabel -->
                    <td><button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#exampleModal" onclick="editRow('${row[0]}')">Edit</button></td>
                    <td><button type="button" class="btn btn-danger" onclick="deleteRow('${row[0]}')">Hapus</button></td>
                </tr>
                `;
                no++;
            });
            tbody.innerHTML = tabel;
        })
        .catch((error) => {
            console.error('Error fetching data:', error);
        });
}

function checkUsernameAndCreateData() {
    // Check if the username already exists
    fetch("https://esolusindosecurity-default-rtdb.firebaseio.com/user.json?auth=05xW10cmdxUBIBwXw4i5edLZy06MbpMRelL5QGf2")
        .then((res) => res.json())
        .then((data) => {
            let usernameExists = false;

            for (let key in data) {
                if (data[key].username === usernameV.value) {
                    usernameExists = true;
                    break;
                }
            }

            if (usernameExists) {
                // Username already exists
                document.getElementById("message").textContent = "Username sudah terdaftar. Silakan pilih username lain.";
                document.getElementById("message").classList.add('text-danger');
            } else {
                // Username is unique, proceed with registration
                createData();
            }
        })
        .catch((error) => {
            console.error('Error checking username:', error);
        });
}

function createData() {
    let roleV = document.querySelector('input[name="role"]:checked'); // Ambil elemen role yang dipilih

    if (!roleV) {
        alert("Please select a role.");
        return;
    }

    let data = {
        nama: namaV.value,
        username: usernameV.value,
        password: passwordV.value,
        alamat: alamatV.value,
        role: roleV.value // Tambahkan role ke dalam data
    };

    fetch("https://esolusindosecurity-default-rtdb.firebaseio.com/user.json?auth=05xW10cmdxUBIBwXw4i5edLZy06MbpMRelL5QGf2", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(data)
    })
    .then((res) => res.json())
    .then(() => {
        document.getElementById("message").textContent = "Registration successful!";
        document.getElementById("message").classList.remove('text-danger');
        document.getElementById("message").classList.add('text-success');
        namaV.value = "";
        usernameV.value = "";
        passwordV.value = "";
        alamatV.value = "";
        roleV.checked = false; // Reset pilihan role
        getData(); // Refresh the data
    })
    .catch((error) => {
        console.error('Error creating data:', error);
        document.getElementById("message").textContent = "Failed to register. Please try again.";
    });
}

function editRow(id) {
    fetch(`https://esolusindosecurity-default-rtdb.firebaseio.com/user/${id}.json?auth=05xW10cmdxUBIBwXw4i5edLZy06MbpMRelL5QGf2`)
        .then((res) => res.json())
        .then((data) => {
            editnama.value = data.nama;
            editusername.value = data.username;
            editpassword.value = data.password;
            editalamat.value = data.alamat;
            editrole.forEach(role => {
                if (role.value === data.role) {
                    role.checked = true;
                }
            });
            getid.value = id;
        })
        .catch((error) => {
            console.error('Error fetching data for edit:', error);
        });
}

function updateData() {
    let selectedRole;
    editrole.forEach(role => {
        if (role.checked) {
            selectedRole = role.value;
        }
    });

    let putdata = {
        nama: editnama.value,
        username: editusername.value,
        password: editpassword.value,
        alamat: editalamat.value,
        role: selectedRole // Tambahkan role ke dalam data yang diupdate
    };

    fetch(`https://esolusindosecurity-default-rtdb.firebaseio.com/user/${getid.value}.json?auth=05xW10cmdxUBIBwXw4i5edLZy06MbpMRelL5QGf2`, {
        method: "PUT",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(putdata)
    })
    .then((res) => res.json())
    .then(() => {
        getData();
        document.querySelector("#exampleModal .btn-close").click(); // Close the modal
    })
    .catch((error) => {
        console.error('Error updating data:', error);
    });
}

function deleteRow(id) {
    fetch(`https://esolusindosecurity-default-rtdb.firebaseio.com/user/${id}.json?auth=05xW10cmdxUBIBwXw4i5edLZy06MbpMRelL5QGf2`, {
        method: "DELETE",
        headers: {
            "Content-Type": "application/json"
        }
    })
    .then(() => {
        getData();
    })
    .catch((error) => {
        console.error('Error deleting data:', error);
    });
}
