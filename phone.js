(function (global) {
  var DEFAULT_PHONE = "15208298293";

  function normalizePhone(raw) {
    if (!raw) return null;
    var p = String(raw).replace(/\D/g, "");
    if (p.length === 11 && /^1[3-9]\d{9}$/.test(p)) return p;
    return null;
  }

  /** Base64 编码手机号，用于 URL 参数（非加密，仅避免明文暴露） */
  function encodePhoneParam(phone) {
    var normalized = normalizePhone(phone);
    if (!normalized) return "";
    try {
      return global.btoa(normalized);
    } catch (e) {
      return normalized;
    }
  }

  /** 解码 URL 参数：支持 Base64 编码与明文（兼容旧链接） */
  function decodePhoneParam(raw) {
    if (!raw) return null;

    var plain = normalizePhone(raw);
    if (plain) return plain;

    try {
      var decoded = global.atob(String(raw).trim());
      return normalizePhone(decoded);
    } catch (e) {
      return null;
    }
  }

  function getPhoneFromUrl(search) {
    var params = new URLSearchParams(search || global.location.search);
    return decodePhoneParam(params.get("p") || params.get("phone"));
  }

  function resolvePhone(search) {
    return getPhoneFromUrl(search) || DEFAULT_PHONE;
  }

  function buildContactUrl(phone, base) {
    var url = new URL("index.html", base || global.location.href);
    url.searchParams.set("p", encodePhoneParam(phone));
    return url.href.split("#")[0];
  }

  function buildOwnerUrl(phone, base) {
    var url = new URL("owner.html", base || global.location.href);
    url.searchParams.set("p", encodePhoneParam(phone));
    return url.href.split("#")[0];
  }

  function formatPhone(phone, masked) {
    if (masked) return phone.slice(0, 3) + " **** " + phone.slice(-4);
    return phone.slice(0, 3) + " " + phone.slice(3, 7) + " " + phone.slice(7);
  }

  global.MoveCarPhone = {
    DEFAULT_PHONE: DEFAULT_PHONE,
    normalizePhone: normalizePhone,
    encodePhoneParam: encodePhoneParam,
    decodePhoneParam: decodePhoneParam,
    getPhoneFromUrl: getPhoneFromUrl,
    resolvePhone: resolvePhone,
    buildContactUrl: buildContactUrl,
    buildOwnerUrl: buildOwnerUrl,
    formatPhone: formatPhone
  };
})(window);
