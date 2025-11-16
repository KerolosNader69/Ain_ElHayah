# كيفية تشغيل Backend Server

## المشكلة
إذا ظهرت رسالة خطأ `ERR_CONNECTION_REFUSED` أو `Backend server is not running`، هذا يعني أن الـ backend server غير شغال.

## الحل السريع

### 1. افتح Terminal في مجلد Backend

```bash
cd backend
```

### 2. ثبت التبعيات (للمرة الأولى فقط)

```bash
npm install
```

### 3. شغّل الـ Server

```bash
npm start
```

أو للتطوير (مع auto-reload):

```bash
npm run dev
```

### 4. تأكد أن الـ Server شغال

يجب أن ترى رسالة:
```
Server is running on port 3001
```

### 5. الآن جرب Login/Signup مرة أخرى

الـ server يجب أن يكون شغال على: `http://localhost:3001`

## ملاحظات

- الـ server يجب أن يبقى شغال أثناء استخدام التطبيق
- إذا أغلقت Terminal، الـ server سيتوقف
- للتطوير، استخدم `npm run dev` لأنه يعيد تشغيل الـ server تلقائياً عند تغيير الكود

## استكشاف الأخطاء

### Port 3001 مستخدم بالفعل؟
```bash
# Windows
netstat -ano | findstr :3001

# Mac/Linux
lsof -i :3001
```

### خطأ في npm install؟
تأكد أن Node.js مثبت:
```bash
node --version
npm --version
```

### مشاكل أخرى؟
راجع ملف `backend/README.md` للمزيد من التفاصيل.

