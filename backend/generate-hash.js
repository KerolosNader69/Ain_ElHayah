const bcrypt = require("bcrypt");

async function run() {
  const password = process.argv[2] || "123456";
  const hash = await bcrypt.hash(password, 10);
  console.log("\n=".repeat(60));
  console.log("Password Hash Generator");
  console.log("=".repeat(60));
  console.log(`Password: ${password}`);
  console.log(`Hash:     ${hash}`);
  console.log("=".repeat(60));
  console.log("\nCopy the hash above and paste it into your database's password_hash column.");
  console.log("\nUsage: node generate-hash.js [password]");
  console.log("Example: node generate-hash.js mypassword123\n");
}

run();
