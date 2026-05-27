const reportService = require('../services/reportService');

async function getMyReport(req, res) {
  const report = await reportService.getCurrentUserReport(req.auth);
  res.status(200).json({ data: report });
}

module.exports = {
  getMyReport
};
