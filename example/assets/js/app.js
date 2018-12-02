import "phoenix_html";
import $ from "jquery";

$(document).ready(() => {
  const appId = "https://localhost";
  const u2f = window.u2f;
  const post = (url, csrf, data) => {
    return $.ajax({
      url: url,
      type: "POST",
      dataType: "json",
      contentType: "application/json",
      data: JSON.stringify(data),
      beforeSend: xhr => {
        xhr.setRequestHeader("X-CSRF-TOKEN", csrf);
      }
    });
  };

  $("#register").click(() => {
    const csrf = $("meta[name='csrf-token']").attr("content");
    post("/u2f/start_registration", csrf).then(
      ({ appId, registerRequests, registeredKeys }) => {
        u2f.register(appId, registerRequests, registeredKeys, response => {
          post("/u2f/finish_registration", csrf, response)
            // NOTE: Handle finishing registration here
                .then(x => console.log("Finished Registration"));
        });
      },
      error => {
        console.error(error);
      }
    );
  });

  $("#sign").click(() => {
    const csrf = $("meta[name='csrf-token']").attr("content");
    post("/u2f/start_authentication", csrf).then(
      ({ challenge, registeredKeys }) => {
        u2f
          .sign(appId, challenge, registeredKeys, response1 => {
            post("/u2f/finish_authentication", csrf, response1).then(
              // NOTE: Handle finishing authentication here
              x => console.log("Finished Authentication")
            );
          });
      },
      error => {
        console.error(error);
      }
    );
  });
});
