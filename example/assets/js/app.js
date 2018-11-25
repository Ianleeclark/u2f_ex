import "phoenix_html";
import $ from "jquery";
import * as u2f from "u2f-api";

const appId = "https://localhost";

$(document).ready(() => {
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
        u2f.register(registerRequests, registeredKeys).then(response => {
          post("/u2f/finish_registration", csrf, response)
            .then(x => console.log(x), error => console.log(error))
            .catch(err => console.error("CATCH: ", err));
        });
      },
      error => {
        console.log("ERRR: ", error);
      }
    );
  });

  $("#sign").click(() => {
    const csrf = $("meta[name='csrf-token']").attr("content");
    post("/u2f/start_authentication", csrf).then(
      ({ challenge, registered_keys }) => {
        // TODO(ian): Make sure to return registeredKeys instead of snake case
        const output = registered_keys.map(
          ({ appId, keyHandle, transports, version }) => {
            return { keyHandle, version, appId, challenge };
          }
        );
        u2f
          .sign(output)
          .then(x =>
            post("/u2f/finish_authentication", csrf, x).then(x =>
              console.log(x)
            )
          )
          .catch("CATCH: ", err);
        console.log("sign: ", response);
      },
      error => {
        console.log(error);
      }
    );
  });
});
