const ProjectVoting = artifacts.require("ProjectVoting");

module.exports = function (deployer) {
  deployer.deploy(ProjectVoting, 100);
};
